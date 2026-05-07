# MQTT Real-Time Integration Guide

`lib/core/network/mqtt_service.dart` provides a reusable MQTT client with auto-reconnect
(exponential backoff), keep-alive, and a stream API. It is registered as a lazy
singleton in `injector.dart`.

## When to connect

Call `.connect(jwtToken: ...)` **after** `AuthSuccess`. Example: subscribe to the
`AuthBloc` stream and bring the MQTT connection up/down with the auth lifecycle.

```dart
// In AuthBloc or a top-level bootstrap:
final mqtt = sl<MqttService>();

authBloc.stream.listen((state) async {
  if (state is AuthSuccess) {
    await mqtt.connect(jwtToken: state.token);
  } else if (state is AuthInitial) {
    await mqtt.disconnect();
  }
});
```

## Subscribing to ThingsBoard topics

For ThingsBoard customer apps, telemetry topics are typically:

| Topic | Purpose |
|---|---|
| `v1/api/attributes` | Server-side attributes for the customer |
| `v1/api/telemetry` | Telemetry stream |
| `v1/devices/{deviceId}/attributes` | Per-device attribute updates |
| `v1/devices/{deviceId}/telemetry` | Per-device telemetry |

Confirm exact topic structure with your ThingsBoard server config — some installs
use the WebSocket telemetry plugin instead of MQTT for customer-side reads.

```dart
final mqtt = sl<MqttService>();
mqtt.subscribe('v1/devices/$deviceId/telemetry');

mqtt.messages$.listen((MqttTopicMessage message) {
  // message.topic, message.payload (JSON string)
  final data = json.decode(message.payload);
  // dispatch DeviceTelemetryReceived(...) into DeviceBloc
});
```

## Wiring into DeviceBloc (sketch)

Add a new event + state to receive real-time updates:

```dart
// device_event.dart
class DeviceTelemetryReceivedEvent extends DeviceEvent {
  final String deviceId;
  final Map<String, dynamic> telemetry;
  const DeviceTelemetryReceivedEvent(this.deviceId, this.telemetry);
  @override
  List<Object?> get props => [deviceId, telemetry];
}

// device_bloc.dart — in constructor:
on<DeviceTelemetryReceivedEvent>(_onTelemetry);

// _onTelemetry: merge new telemetry into the matching DeviceEntity in DeviceLoaded
```

Then have a small adapter that listens to `MqttService.messages$` and converts
to `DeviceTelemetryReceivedEvent`s.

## Connection state UI

The service exposes `state$` so you can show a "reconnecting" badge:

```dart
StreamBuilder<MqttConnectionState>(
  stream: sl<MqttService>().state$,
  builder: (context, snap) {
    final s = snap.data ?? MqttConnectionState.disconnected;
    return s == MqttConnectionState.connected
        ? const SizedBox.shrink()
        : const Banner(...);
  },
)
```

## Configuration

Set these via `--dart-define` (see `docs/BUILD.md`):
- `MQTT_HOST` — defaults to `performentmarketing.ddnsgeek.com`
- `MQTT_PORT` — defaults to `1883`. Use `8883` and set `useTls: true` for TLS.

## Why JWT-as-username for ThingsBoard

ThingsBoard's MQTT broker accepts the user JWT (the same one used for REST `X-Authorization`)
as the MQTT username, leaving the password blank. The token expires — when it does,
the broker disconnects, the service's reconnect kicks in, and the next connect attempt
will fail until `AuthBloc` refreshes the token. Wire the refresh-token flow to call
`MqttService.connect(jwtToken: newToken)` whenever a new access token lands.
