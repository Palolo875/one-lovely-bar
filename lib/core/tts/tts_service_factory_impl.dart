import 'tts_service.dart';

import 'tts_service_web.dart'
    if (dart.library.io) 'tts_service_io.dart';

TtsService createTtsService() {
  return TtsServiceImpl();
}
