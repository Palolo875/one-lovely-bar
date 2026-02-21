import 'background_scheduler.dart';

import 'background_scheduler_web.dart'
    if (dart.library.io) 'background_scheduler_io.dart';

BackgroundScheduler createBackgroundScheduler() {
  return BackgroundSchedulerImpl();
}
