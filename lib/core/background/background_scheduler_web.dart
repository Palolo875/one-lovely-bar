import 'package:weathernav/core/background/background_scheduler.dart';

BackgroundScheduler createBackgroundScheduler() {
  return BackgroundSchedulerImpl();
}

class BackgroundSchedulerImpl implements BackgroundScheduler {
  @override
  Future<void> init() async {
    return;
  }
}
