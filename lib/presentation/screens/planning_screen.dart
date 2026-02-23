import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/models/place_suggestion.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/route_provider.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  final _startLatController = TextEditingController(text: '48.8566');
  final _startLngController = TextEditingController(text: '2.3522');
  final _endLatController = TextEditingController(text: '48.8049');
  final _endLngController = TextEditingController(text: '2.1204');
  DateTime _departureTime = DateTime.now();

  String _profileToRoutingProfile(ProfileType type) {
    switch (type) {
      case ProfileType.universal:
        return 'driver';
      case ProfileType.cyclist:
        return 'cyclist';
      case ProfileType.hiker:
        return 'hiker';
      case ProfileType.driver:
        return 'driver';
      case ProfileType.nautical:
        return 'driver';
      case ProfileType.paraglider:
        return 'driver';
      case ProfileType.camper:
        return 'driver';
    }
  }

  @override
  void dispose() {
    _startLatController.dispose();
    _startLngController.dispose();
    _endLatController.dispose();
    _endLngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planifier une sortie'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quand partez-vous ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _departureTime,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 14)),
                );
                if (pickedDate == null) return;

                if (!context.mounted) return;

                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_departureTime),
                );
                if (pickedTime == null) return;

                setState(() {
                  _departureTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar),
                    const SizedBox(width: 12),
                    Text(
                      '${_departureTime.day.toString().padLeft(2, '0')}/${_departureTime.month.toString().padLeft(2, '0')}/${_departureTime.year} '
                      '${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Itinéraire',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCoordinateRow(
              icon: LucideIcons.mapPin,
              title: 'Départ',
              latController: _startLatController,
              lngController: _startLngController,
            ),
            const SizedBox(height: 12),
            _buildCoordinateRow(
              icon: LucideIcons.navigation,
              title: 'Arrivée',
              latController: _endLatController,
              lngController: _endLngController,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final startLat = double.tryParse(
                    _startLatController.text.trim(),
                  );
                  final startLng = double.tryParse(
                    _startLngController.text.trim(),
                  );
                  final endLat = double.tryParse(_endLatController.text.trim());
                  final endLng = double.tryParse(_endLngController.text.trim());

                  if (startLat == null ||
                      startLng == null ||
                      endLat == null ||
                      endLng == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez entrer des coordonnées valides.',
                        ),
                      ),
                    );
                    return;
                  }

                  final req = RouteRequest(
                    startLat: startLat,
                    startLng: startLng,
                    endLat: endLat,
                    endLng: endLng,
                    profile: _profileToRoutingProfile(profile.type),
                    departureTime: _departureTime,
                  );

                  context.push('/simulation', extra: req);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Simuler la météo sur le trajet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow({
    required IconData icon,
    required String title,
    required TextEditingController latController,
    required TextEditingController lngController,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final result = await context.push<PlaceSuggestion>(
                    '/search?title=${Uri.encodeComponent(title)}',
                  );
                  if (result == null) return;

                  latController.text = result.latitude.toStringAsFixed(6);
                  lngController.text = result.longitude.toStringAsFixed(6);
                },
                child: const Text('Rechercher'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: latController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: lngController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
