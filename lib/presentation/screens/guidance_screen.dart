import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/app_failure.dart';
import '../providers/route_instructions_provider.dart';
import '../providers/route_provider.dart';

class GuidanceScreen extends ConsumerWidget {
  final RouteRequest request;

  const GuidanceScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructionsAsync = ref.watch(routeInstructionsProvider(request));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guidage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: instructionsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('Aucune instruction disponible.'));
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final ins = items[i];
                final metaParts = <String>[];
                if (ins.distanceKm != null) metaParts.add('${ins.distanceKm!.toStringAsFixed(2)} km');
                if (ins.timeSeconds != null) metaParts.add('${(ins.timeSeconds! / 60).round()} min');

                return ListTile(
                  leading: Text('${i + 1}'),
                  title: Text(ins.instruction),
                  subtitle: metaParts.isEmpty ? null : Text(metaParts.join(' • ')),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) {
            final msg = err is AppFailure ? err.message : err.toString();
            return Center(child: Text(msg));
          },
        ),
      ),
    );
  }
}
