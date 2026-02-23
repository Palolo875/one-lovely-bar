import 'package:weathernav/core/background/background_scheduler.dart';
import 'package:weathernav/core/background/workmanager_tasks.dart';
import 'package:workmanager/workmanager.dart';

BackgroundScheduler createBackgroundScheduler() {
  return BackgroundSchedulerImpl();
}

class BackgroundSchedulerImpl implements BackgroundScheduler {
  @override
  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      WorkmanagerTasks.weatherRefreshTask,
      WorkmanagerTasks.weatherRefreshTask,
      frequency: const Duration(hours: 1),
    );
  }
}
