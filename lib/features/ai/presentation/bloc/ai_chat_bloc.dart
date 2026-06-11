import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/device/domain/entities/device_entity.dart';
import '../../../../features/device/domain/usecases/get_customer_devices.dart';
import '../../../../features/device/domain/usecases/send_device_command.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_chat_message.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();
  @override
  List<Object?> get props => [];
}

class SendMessage extends AiChatEvent {
  final String content;
  const SendMessage(this.content);
  @override
  List<Object?> get props => [content];
}

class AiChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isThinking;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isThinking = false,
    this.error,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    String? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isThinking, error];
}

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final SendChatMessage _send;
  final GetCustomerDevices _getDevices;
  final SendDeviceCommand _sendCommand;

  AiChatBloc(this._send, this._getDevices, this._sendCommand)
      : super(const AiChatState()) {
    on<SendMessage>(_onSend);
    on<ControlDevice>(_onControlDevice);
  }

  Future<void> _onSend(SendMessage e, Emitter<AiChatState> emit) async {
    final userMsg = ChatMessage(
      role: ChatRole.user,
      content: e.content,
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      error: null,
    ));

    final command = _parseDeviceCommand(e.content);
    if (command != null) {
      await _handleDeviceCommand(command, e.content, emit);
      return;
    }

    final result = await _send(e.content);
    result.fold(
      // Luôn trả lời bằng bubble — set mỗi `error` thì UI không render gì,
      // user tưởng chat chết. Model on-device thiếu (Android/iOS cũ) →
      // hướng dẫn các lệnh vẫn dùng được.
      (f) {
        final unavailable = f.message.contains('Foundation Models') ||
            f.message.contains('Platform error');
        _emitReply(
          unavailable
              ? 'AI chat is not available on this device yet. I can still '
                  'control your curtains — try "Open the curtain", or use '
                  '/devices, /scenes, /help.'
              : (f.message.isNotEmpty
                  ? f.message
                  : 'Sorry, something went wrong. Please try again.'),
          emit,
        );
      },
      (reply) => _emitReply(reply, emit),
    );
  }

  Future<void> _onControlDevice(
    ControlDevice e,
    Emitter<AiChatState> emit,
  ) async {
    final label = e.action == 'OPEN'
        ? 'Opening'
        : e.action == 'CLOSE'
            ? 'Closing'
            : 'Stopping';
    final userMsg = ChatMessage(
      role: ChatRole.user,
      content: '$label ${e.deviceName}',
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      error: null,
    ));

    final result = await _sendCommand(e.deviceId, e.action);
    result.fold(
      (f) => _emitReply(
        'Failed: ${f.message.isNotEmpty ? f.message : 'Device may be offline.'}',
        emit,
      ),
      (_) => _emitReply('$label ${e.deviceName}.', emit),
    );
  }

  Future<void> _handleDeviceCommand(
    _DeviceCommand cmd,
    String originalMessage,
    Emitter<AiChatState> emit,
  ) async {
    final devicesResult = await _getDevices();
    final devices = devicesResult.fold((_) => <DeviceEntity>[], (d) => d);

    if (devices.isEmpty) {
      _emitReply(
          'No devices found. Add a curtain first from the Home tab.', emit);
      return;
    }

    final target = _findDevice(devices, cmd.deviceQuery, originalMessage);
    if (target == null) {
      final names = devices.map((d) => d.name).join(', ');
      _emitReply(
        'Could not find that device. Your devices: $names',
        emit,
      );
      return;
    }

    final result = await _sendCommand(target.id, cmd.action);
    final label = cmd.action == 'OPEN'
        ? 'Opening'
        : cmd.action == 'CLOSE'
            ? 'Closing'
            : 'Stopping';
    result.fold(
      (f) => _emitReply(
        'Failed to ${cmd.action.toLowerCase()} ${target.name}: '
        '${f.message.isNotEmpty ? f.message : 'Device may be offline.'}',
        emit,
      ),
      (_) => _emitReply('$label ${target.name}.', emit),
    );
  }

  Future<List<DeviceEntity>> getDeviceList() async {
    final result = await _getDevices();
    return result.fold((_) => <DeviceEntity>[], (d) => d);
  }

  void _emitReply(String text, Emitter<AiChatState> emit) {
    final msg = ChatMessage(
      role: ChatRole.assistant,
      content: text,
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(
      messages: [...state.messages, msg],
      isThinking: false,
    ));
  }

  DeviceEntity? _findDevice(
    List<DeviceEntity> devices,
    String? query,
    String originalMessage,
  ) {
    final msg = originalMessage.toLowerCase().trim();

    // 1. Try exact device name match from the full message
    for (final d in devices) {
      if (msg.contains(d.name.toLowerCase())) return d;
    }

    // 2. Try query (extracted room/device keyword)
    if (query != null) {
      final q = query.toLowerCase();
      for (final d in devices) {
        final n = d.name.toLowerCase();
        if (n.contains(q) || q.contains(n)) return d;
      }

      // 3. Room alias mapping
      const roomAliases = {
        'bedroom': ['phòng ngủ', 'phong ngu'],
        'living room': ['phòng khách', 'phong khach'],
        'kitchen': ['bếp', 'bep'],
        'office': ['phòng làm việc', 'văn phòng'],
        'bathroom': ['phòng tắm', 'phong tam'],
      };
      for (final entry in roomAliases.entries) {
        if (q.contains(entry.key) ||
            entry.value.any((a) => q.contains(a) || a.contains(q))) {
          for (final d in devices) {
            final n = d.name.toLowerCase();
            if (n.contains(entry.key) ||
                entry.value.any((a) => n.contains(a))) {
              return d;
            }
          }
        }
      }
    }

    // 4. If only one device, use it as default
    if (devices.length == 1) return devices.first;

    return null;
  }

  _DeviceCommand? _parseDeviceCommand(String message) {
    final m = message.toLowerCase().trim();

    String? action;
    if (m.contains('open') || m.contains('mở')) {
      action = 'OPEN';
    } else if (m.contains('close') || m.contains('shut') || m.contains('đóng')) {
      action = 'CLOSE';
    } else if (m.contains('stop') || m.contains('dừng') || m.contains('pause')) {
      action = 'STOP';
    }
    if (action == null) return null;

    // Strip action keywords to find the device query
    var query = m
        .replaceAll('open', '')
        .replaceAll('close', '')
        .replaceAll('shut', '')
        .replaceAll('stop', '')
        .replaceAll('pause', '')
        .replaceAll('mở', '')
        .replaceAll('đóng', '')
        .replaceAll('dừng', '')
        .replaceAll('the', '')
        .replaceAll('curtain', '')
        .replaceAll('rèm', '')
        .trim();

    return _DeviceCommand(
      action: action,
      deviceQuery: query.isEmpty ? null : query,
    );
  }
}

class ControlDevice extends AiChatEvent {
  final String deviceId;
  final String deviceName;
  final String action;

  const ControlDevice({
    required this.deviceId,
    required this.deviceName,
    required this.action,
  });

  @override
  List<Object?> get props => [deviceId, deviceName, action];
}

class _DeviceCommand {
  final String action;
  final String? deviceQuery;

  const _DeviceCommand({required this.action, this.deviceQuery});
}
