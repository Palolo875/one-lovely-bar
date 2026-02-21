import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/failures/app_failure.dart';
import '../providers/trip_history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(tripHistoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: listAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucun trajet enregistré.'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = items[i];
              final when = DateFormat('dd/MM HH:mm').format(t.createdAt);
              final dep = t.departureTime == null ? null : DateFormat('dd/MM HH:mm').format(t.departureTime!);

              return ListTile(
                title: Text('${t.distanceKm.toStringAsFixed(1)} km • ${t.durationMinutes.toStringAsFixed(0)} min'),
                subtitle: Text(dep == null ? 'Enregistré: $when' : 'Départ: $dep • Enregistré: $when'),
                trailing: Text(t.profile),
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
    );
  }
}
