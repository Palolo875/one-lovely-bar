import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weathernav/presentation/widgets/app_loading_indicator.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/itinerary');
    });

    return const Scaffold(body: Center(child: AppLoadingIndicator(size: 32)));
  }
}
