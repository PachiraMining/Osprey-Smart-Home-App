import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/foundation_model_repository.dart';

const _systemPrompt = '''
You are the Osprey Life assistant, a concise on-device AI for a motorized-curtain
app. Help the user with setup, troubleshooting, and automation ideas.
Keep replies under 4 sentences. If the user asks something off-topic,
redirect to curtain control.
''';

class SendChatMessage {
  final FoundationModelRepository _fm;

  SendChatMessage(this._fm);

  Future<Either<Failure, String>> call(String userMessage) async {
    final available = await _fm.isAvailable();
    if (!available) {
      // Apple Intelligence not enabled or device not capable.
      // Use a deterministic rule-based response so the chat is still useful.
      return Right(_ruleBasedReply(userMessage));
    }
    final prompt = '$_systemPrompt\n\nUser: $userMessage\nAssistant:';
    final result = await _fm.complete(prompt);
    return result.fold(
      // If the on-device call fails at runtime (model busy, etc), fall back to
      // the rule-based reply rather than surfacing a raw error to the user.
      (_) => Right(_ruleBasedReply(userMessage)),
      Right.new,
    );
  }

  String _ruleBasedReply(String message) {
    final m = message.toLowerCase().trim();

    if (m.isEmpty) {
      return 'Tell me what you want to do with your curtains — try "open the bedroom curtain" or type /help.';
    }
    if (m.contains('hi') || m.contains('hello') || m.contains('hey') ||
        m.contains('xin chào') || m.contains('chao')) {
      return 'Hi — I\'m the Osprey Life assistant. Try /help to see commands, or just tell me which curtain to control.';
    }
    if (m.contains('open') || m.contains('mở')) {
      final room = _detectRoom(m);
      if (room != null) {
        return 'Opening the $room curtain. Open Devices from the drawer to confirm the action ran.';
      }
      return 'I can open any curtain. Tell me which room (bedroom, living room, kitchen), or tap one in Devices.';
    }
    if (m.contains('close') || m.contains('shut') || m.contains('đóng')) {
      final room = _detectRoom(m);
      if (room != null) {
        return 'Closing the $room curtain. Check Devices to confirm.';
      }
      return 'I can close any curtain. Say which room or open Devices from the drawer.';
    }
    if (m.contains('schedule') || m.contains('automation') ||
        m.contains('automate') || m.contains('lên lịch')) {
      return 'Open the drawer → "Tap-to-Run scenes" to create a one-tap routine. You can chain device actions and delays.';
    }
    if (m.contains('weather') || m.contains('thời tiết') ||
        m.contains('sun') || m.contains('rain')) {
      return 'Weather-aware suggestions appear here automatically when conditions favour a curtain action. No setup needed.';
    }
    if (m.contains('sleep') || m.contains('wake') || m.contains('alarm') ||
        m.contains('ngủ')) {
      return 'When Apple Health sleep tracking is granted, I\'ll suggest opening shades just before your wake time. Grant access in iOS Settings → Privacy → Health.';
    }
    if (m.contains('help') || m.contains('how') || m.contains('what') ||
        m.contains('?')) {
      return 'Quick start: type "/devices" to see your curtains, "/scenes" for tap-to-run routines, or just say what you want — "open the bedroom curtain", "close everything".';
    }
    if (m.contains('apple intelligence') || m.contains('ai') ||
        m.contains('foundation')) {
      return 'On-device Apple Intelligence is currently disabled on this iPhone. Enable it in iOS Settings → Apple Intelligence & Siri for richer conversation.';
    }
    // Generic fallback
    return 'I heard: "$message". On-device AI is off right now, so I can only handle direct curtain commands. Try "open the kitchen curtain" or /help.';
  }

  String? _detectRoom(String m) {
    const rooms = {
      'bedroom': 'bedroom',
      'phòng ngủ': 'bedroom',
      'living room': 'living room',
      'living': 'living room',
      'phòng khách': 'living room',
      'phong khach': 'living room',
      'kitchen': 'kitchen',
      'bếp': 'kitchen',
      'office': 'office',
      'phòng làm việc': 'office',
      'bathroom': 'bathroom',
      'phòng tắm': 'bathroom',
    };
    for (final key in rooms.keys) {
      if (m.contains(key)) return rooms[key];
    }
    return null;
  }
}
