import 'package:flutter/services.dart';

/// Method-channel bridge to `ios/Runner/FoundationModelsHandler.swift`.
class FoundationModelsDataSource {
  static const _channel = MethodChannel('io.dracaena.curtainai/foundation_models');

  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Throws [PlatformException] on failure — callers wrap into Either.
  Future<String> complete(String prompt) async {
    final result = await _channel.invokeMethod<String>(
      'complete',
      <String, dynamic>{'prompt': prompt},
    );
    return result ?? '';
  }
}
