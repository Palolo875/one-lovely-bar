import 'package:weathernav/core/tts/tts_service.dart';

import 'package:weathernav/core/tts/tts_service_web.dart'
    if (dart.library.io) 'tts_service_io.dart';

TtsService createTtsService() {
  return TtsServiceImpl();
}
