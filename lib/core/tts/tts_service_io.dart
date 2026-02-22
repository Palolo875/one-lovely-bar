import 'package:flutter_tts/flutter_tts.dart';

import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/tts/tts_service.dart';

class TtsServiceImpl implements TtsService {
  final FlutterTts _tts = FlutterTts();

  bool _speaking = false;

  @override
  Future<void> speakLines(List<String> lines) async {
    _speaking = true;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(0.5);
      for (final l in lines) {
        if (!_speaking) break;
        await _tts.speak(l);
        await _tts.awaitSpeakCompletion(true);
      }
    } catch (e, st) {
      AppLogger.warn('TTS speak failed', name: 'tts', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> stop() async {
    _speaking = false;
    try {
      await _tts.stop();
    } catch (e, st) {
      AppLogger.warn('TTS stop failed', name: 'tts', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
  }
}
