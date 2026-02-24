import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/presentation/providers/trip_history_provider.dart';
import 'package:weathernav/presentation/widgets/app_loading_indicator.dart';
import 'package:weathernav/presentation/widgets/app_state_message.dart';

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
            return AppStateMessage(
              icon: Icons.history,
              iconColor: scheme.primary,
              title: 'Aucun trajet enregistré',
              message:
                  'Sauvegarde un trajet depuis l’onglet Itinéraire ou la simulation pour le retrouver ici.',
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
          return AppStateMessage(
            icon: Icons.error_outline,
            iconColor: scheme.error,
            title: 'Erreur',
            message: msg,
            action: OutlinedButton(
              onPressed: () => ref.invalidate(tripHistoryListProvider),
              child: const Text('Réessayer'),
            ),
          );
        },
      ),
    );
  }
}
