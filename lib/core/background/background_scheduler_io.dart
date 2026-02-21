import 'package:workmanager/workmanager.dart';

import 'background_scheduler.dart';
import 'workmanager_tasks.dart';

class BackgroundSchedulerImpl implements BackgroundScheduler {
  @override
  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      WorkmanagerTasks.weatherRefreshTask,
      WorkmanagerTasks.weatherRefreshTask,
      frequency: const Duration(hours: 1),
    );
  }
}
