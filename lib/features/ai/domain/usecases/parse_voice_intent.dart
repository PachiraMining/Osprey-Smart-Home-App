import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/voice_intent.dart';
import '../repositories/foundation_model_repository.dart';

/// Parses a spoken transcript into a [VoiceIntent].
///
/// Strategy:
///   1. Ask the on-device Foundation Model to emit a strict JSON object.
///   2. Decode it; on any failure fall back to a deterministic keyword
///      parser so the UI always shows a response (matches the plan's
///      "Apple-Intelligence-incapable device" mitigation).
class ParseVoiceIntent {
  final FoundationModelRepository _fm;

  ParseVoiceIntent(this._fm);

  Future<Either<Failure, VoiceIntent>> call(String transcript) async {
    final fmAvailable = await _fm.isAvailable();
    if (fmAvailable) {
      final prompt = _buildPrompt(transcript);
      final result = await _fm.complete(prompt);
      final parsed = result.fold((_) => null, (raw) => _tryDecode(raw, transcript));
      if (parsed != null) return Right(parsed);
    }
    return Right(_fallbackParse(transcript));
  }

  String _buildPrompt(String transcript) {
    return '''
You are a parser for a smart-curtain app. Convert the user's spoken request
into a strict JSON object with these fields and nothing else:
{
  "device_hint": "<room or device name, empty if not mentioned>",
  "action": "open" | "close" | "stop" | "set_position",
  "position": <integer 0-100, only when action is set_position; otherwise null>
}
Input: "$transcript"
Output:
''';
  }

  VoiceIntent? _tryDecode(String raw, String transcript) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final json = jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
      final actionStr = (json['action'] as String? ?? '').toLowerCase();
      final action = switch (actionStr) {
        'open' => VoiceAction.open,
        'close' => VoiceAction.close,
        'stop' => VoiceAction.stop,
        'set_position' => VoiceAction.setPosition,
        _ => VoiceAction.unknown,
      };
      final pos = json['position'];
      return VoiceIntent(
        deviceHint: (json['device_hint'] as String? ?? '').trim(),
        action: action,
        position: pos is int ? pos.clamp(0, 100) : null,
        transcript: transcript,
      );
    } catch (_) {
      return null;
    }
  }

  VoiceIntent _fallbackParse(String transcript) {
    final t = transcript.toLowerCase();
    VoiceAction action = VoiceAction.unknown;
    int? position;

    if (t.contains('stop')) {
      action = VoiceAction.stop;
    } else if (t.contains('open')) {
      action = VoiceAction.open;
    } else if (t.contains('close') || t.contains('shut')) {
      action = VoiceAction.close;
    }

    final match = RegExp(r'(\d{1,3})\s*(?:percent|%)?').firstMatch(t);
    if (match != null) {
      final p = int.tryParse(match.group(1) ?? '');
      if (p != null && p >= 0 && p <= 100) {
        position = p;
        action = VoiceAction.setPosition;
      }
    }

    String hint = '';
    for (final room in const [
      'bedroom', 'living room', 'kitchen', 'office', 'bathroom', 'dining'
    ]) {
      if (t.contains(room)) {
        hint = room;
        break;
      }
    }

    return VoiceIntent(
      deviceHint: hint,
      action: action,
      position: position,
      transcript: transcript,
    );
  }
}
