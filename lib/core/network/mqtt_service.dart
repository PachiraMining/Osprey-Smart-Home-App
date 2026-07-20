import 'dart:async';
import 'dart:developer' as developer;

import 'package:mqtt_client/mqtt_client.dart' hide MqttConnectionState;
import 'package:mqtt_client/mqtt_client.dart' as mqtt_pkg;
import 'package:mqtt_client/mqtt_server_client.dart';

import '../config/app_config.dart';

/// Connection lifecycle states for the MQTT broker.
enum MqttConnectionState { disconnected, connecting, connected, reconnecting }

/// One MQTT message: topic + payload + QoS.
class MqttTopicMessage {
  final String topic;
  final String payload;
  final MqttQos qos;

  const MqttTopicMessage({
    required this.topic,
    required this.payload,
    this.qos = MqttQos.atLeastOnce,
  });
}

/// Real-time MQTT client for ThingsBoard device telemetry and state updates.
///
/// Auth: ThingsBoard accepts JWT tokens as MQTT username, password empty.
///   - Customer-side topics: `v1/api/attributes`, `v1/api/telemetry`
///   - Device-side topics  : `v1/devices/me/telemetry`, `v1/devices/me/attributes`
///
/// Resilience:
///   - Auto-reconnect with exponential backoff (5s → 60s)
///   - Keep-alive 60s
///   - Clean session by default (set [cleanSession] false to persist subs)
class MqttService {
  final String _clientIdPrefix;
  final String _host;
  final int _port;
  final int _keepAliveSeconds;
  final bool _useTls;

  MqttServerClient? _client;
  String? _username;

  final _stateController =
      StreamController<MqttConnectionState>.broadcast();
  final _messageController = StreamController<MqttTopicMessage>.broadcast();

  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _disposed = false;

  /// Set while [updateToken] tears down the old connection, so the
  /// disconnect-triggered auto-reconnect doesn't race the immediate reconnect
  /// we do with the fresh token.
  bool _suppressReconnect = false;

  /// Subscriptions to re-establish after a reconnect.
  final Map<String, MqttQos> _activeSubscriptions = {};

  MqttService({
    String clientIdPrefix = 'osprey-life-app',
    String host = AppConfig.mqttHost,
    int port = AppConfig.mqttPort,
    int keepAliveSeconds = 60,
    bool useTls = AppConfig.mqttUseTls,
  })  : _clientIdPrefix = clientIdPrefix,
        _host = host,
        _port = port,
        _keepAliveSeconds = keepAliveSeconds,
        _useTls = useTls;

  Stream<MqttConnectionState> get state$ => _stateController.stream;

  Stream<MqttTopicMessage> get messages$ => _messageController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == mqtt_pkg.MqttConnectionState.connected;

  /// Connect using a ThingsBoard JWT (passed as MQTT username).
  /// Throws on connection failure; safe to call once at app start after login.
  Future<void> connect({required String jwtToken}) async {
    if (_disposed) throw StateError('MqttService disposed');
    _username = jwtToken;

    final clientId = '$_clientIdPrefix-${DateTime.now().millisecondsSinceEpoch}';
    final client = MqttServerClient.withPort(_host, clientId, _port);
    client.keepAlivePeriod = _keepAliveSeconds;
    client.autoReconnect = false; // we manage backoff ourselves
    client.logging(on: false);
    if (_useTls) {
      client.secure = true;
    }
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = (topic) =>
        developer.log('MQTT subscribed: $topic', name: 'mqtt');
    client.onSubscribeFail = (topic) =>
        developer.log('MQTT subscribe FAILED: $topic', name: 'mqtt');

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(jwtToken, '')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    _client = client;
    _stateController.add(MqttConnectionState.connecting);

    try {
      await client.connect();
    } on Exception catch (e) {
      developer.log('MQTT connect failed: $e', name: 'mqtt', error: e);
      client.disconnect();
      _stateController.add(MqttConnectionState.disconnected);
      _scheduleReconnect();
      rethrow;
    }
  }

  /// Swap the JWT the connection authenticates with — call after a token
  /// refresh so the broker keeps accepting us past the old token's expiry.
  ///
  /// If we've never connected, this just stores the token for the next
  /// [connect]. If a connection exists, it is bounced and re-established with
  /// the fresh credential (active subscriptions are restored by [_onConnected]).
  /// A no-op when the token is unchanged or the service is disposed.
  Future<void> updateToken(String jwtToken) async {
    if (_disposed || jwtToken.isEmpty || jwtToken == _username) return;
    _username = jwtToken;

    // Never connected → nothing to bounce; connect() will pick up _username.
    if (_client == null) return;

    _reconnectTimer?.cancel();
    _reconnectAttempt = 0;
    _suppressReconnect = true;
    _client?.disconnect(); // may synchronously fire _onDisconnected
    _suppressReconnect = false;

    try {
      await connect(jwtToken: jwtToken);
    } catch (_) {
      // connect() already scheduled its own backoff reconnect on failure.
    }
  }

  /// Subscribe to [topic] at [qos]. Stored so it survives reconnects.
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    _activeSubscriptions[topic] = qos;
    _client?.subscribe(topic, qos);
  }

  /// Unsubscribe from [topic] and forget the saved subscription.
  void unsubscribe(String topic) {
    _activeSubscriptions.remove(topic);
    _client?.unsubscribe(topic);
  }

  /// Publish a JSON [payload] to [topic].
  void publish(String topic, String payload,
      {MqttQos qos = MqttQos.atLeastOnce, bool retain = false}) {
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client?.publishMessage(topic, qos, builder.payload!, retain: retain);
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _stateController.add(MqttConnectionState.disconnected);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _reconnectTimer?.cancel();
    _client?.disconnect();
    await _stateController.close();
    await _messageController.close();
  }

  // ---------- Internal ----------

  void _onConnected() {
    developer.log('MQTT connected to $_host:$_port', name: 'mqtt');
    _reconnectAttempt = 0;
    _stateController.add(MqttConnectionState.connected);

    final updates = _client?.updates;
    if (updates != null) {
      updates.listen(_onMessages);
    }

    // Re-subscribe to any topics that were active before reconnect.
    for (final entry in _activeSubscriptions.entries) {
      _client?.subscribe(entry.key, entry.value);
    }
  }

  void _onDisconnected() {
    developer.log('MQTT disconnected', name: 'mqtt');
    _stateController.add(MqttConnectionState.disconnected);
    if (!_disposed) _scheduleReconnect();
  }

  void _onMessages(List<MqttReceivedMessage<mqtt_pkg.MqttMessage>> events) {
    for (final event in events) {
      final recv = event.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        recv.payload.message,
      );
      _messageController.add(
        MqttTopicMessage(topic: event.topic, payload: payload),
      );
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _username == null || _suppressReconnect) return;
    _reconnectAttempt += 1;
    final backoffSeconds = (5 * (1 << (_reconnectAttempt - 1))).clamp(5, 60);
    developer.log(
      'MQTT reconnect in ${backoffSeconds}s (attempt $_reconnectAttempt)',
      name: 'mqtt',
    );
    _stateController.add(MqttConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: backoffSeconds), () {
      if (_username != null) {
        connect(jwtToken: _username!).catchError((_) {});
      }
    });
  }
}
