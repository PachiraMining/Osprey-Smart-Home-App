import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Wraps the `speech_to_text` plugin so the BLoC only depends on a
/// narrow surface (init / listen / stop) and stays testable via mocks.
class SpeechToTextDataSource {
  final stt.SpeechToText _speech;

  SpeechToTextDataSource({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  bool _initialized = false;

  Future<bool> ensureInitialized() async {
    if (_initialized) return _speech.isAvailable;
    _initialized = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _initialized;
  }

  Future<void> startListening({
    required void Function(String transcript, bool isFinal) onResult,
  }) async {
    final ok = await ensureInitialized();
    if (!ok) return;
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
      ),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
