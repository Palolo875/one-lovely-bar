import 'package:weathernav/core/background/background_scheduler.dart'
    if (dart.library.html) 'background_scheduler_web.dart'
    if (dart.library.io) 'background_scheduler_io.dart';

BackgroundScheduler createBackgroundScheduler() {
  return BackgroundSchedulerWeb();
}
