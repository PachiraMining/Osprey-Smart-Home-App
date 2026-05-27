import 'package:equatable/equatable.dart';

/// Parsed natural-language intent for curtain control.
///
/// Produced by [ParseVoiceIntent] from a speech transcript and consumed by
/// the existing `SendDeviceCommand` usecase.
class VoiceIntent extends Equatable {
  /// Device target hint — fuzzy room/device name extracted from speech.
  /// Empty string means "all curtains" / no target specified.
  final String deviceHint;

  /// Action verb: open | close | stop | set_position.
  final VoiceAction action;

  /// Target position percentage 0..100, only meaningful for [VoiceAction.setPosition].
  final int? position;

  /// Original transcript, kept for telemetry / chat display.
  final String transcript;

  const VoiceIntent({
    required this.deviceHint,
    required this.action,
    required this.transcript,
    this.position,
  });

  @override
  List<Object?> get props => [deviceHint, action, position, transcript];
}

enum VoiceAction {
  open,
  close,
  stop,
  setPosition,
  unknown,
}
