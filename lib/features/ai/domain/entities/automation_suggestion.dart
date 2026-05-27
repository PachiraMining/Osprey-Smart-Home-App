import 'package:equatable/equatable.dart';

/// A repeating-pattern automation discovered from local usage logs.
///
/// Surfaced as a card on the Home tab — user can tap "Create scene" to
/// materialize it via the existing `SceneBloc.CreateScene` flow.
class AutomationSuggestion extends Equatable {
  final String deviceId;
  final String deviceLabel;

  /// 1=Monday..7=Sunday (ISO 8601). Multiple values = a weekly window.
  final List<int> weekdays;

  /// Hour-of-day bucket (0..23) where the pattern fires.
  final int hour;

  /// The target action (open / close / set 50%, etc.).
  final String action;

  /// Number of times this pattern repeated in the analysed window.
  final int occurrences;

  /// Confidence 0..1 — based on consistency vs noise in the log.
  final double confidence;

  const AutomationSuggestion({
    required this.deviceId,
    required this.deviceLabel,
    required this.weekdays,
    required this.hour,
    required this.action,
    required this.occurrences,
    required this.confidence,
  });

  @override
  List<Object?> get props =>
      [deviceId, weekdays, hour, action, occurrences, confidence];
}
