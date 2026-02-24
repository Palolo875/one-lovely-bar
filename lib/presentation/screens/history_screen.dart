import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/presentation/providers/trip_history_provider.dart';
import 'package:weathernav/presentation/widgets/app_loading_indicator.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(tripHistoryListProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: listAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 44, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun trajet enregistré',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sauvegarde un trajet depuis l’onglet Itinéraire ou la simulation pour le retrouver ici.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = items[i];
              final when = DateFormat('dd/MM HH:mm').format(t.createdAt);
              final depTime = t.departureTime;
              final dep = depTime == null
                  ? null
                  : DateFormat('dd/MM HH:mm').format(depTime);

              return ListTile(
                title: Text(
                  '${t.distanceKm.toStringAsFixed(1)} km • ${t.durationMinutes.toStringAsFixed(0)} min',
                ),
                subtitle: Text(
                  dep == null
                      ? 'Enregistré: $when'
                      : 'Départ: $dep • Enregistré: $when',
                ),
                trailing: Text(t.profile),
              );
            },
          );
        },
        loading: () => const Center(child: AppLoadingIndicator(size: 32)),
        error: (err, st) {
          final msg = err is AppFailure ? err.message : err.toString();
          return Center(child: Text(msg));
        },
      ),
    );
  }
}
