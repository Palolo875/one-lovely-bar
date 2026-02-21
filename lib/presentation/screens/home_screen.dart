import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/failures/app_failure.dart';
import '../providers/profile_provider.dart';
import '../providers/current_weather_provider.dart';
import '../widgets/profile_switcher.dart';
import '../widgets/weather_timeline.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapLibreMapController? mapController;

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(profileNotifierProvider);
    final parisWeather = ref.watch(
      currentWeatherProvider(const LatLngRequest(lat: 48.8566, lng: 2.3522)),
    );

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) context.push('/planning');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.calendar), label: 'Planifier'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profil'),
        ],
      ),
      body: Stack(
        children: [
          // Map
          MapLibreMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8566, 2.3522), // Paris
              zoom: 12.0,
            ),
            styleString: 'https://tiles.openfreemap.org/styles/positron',
            myLocationEnabled: true,
            trackCameraPosition: true,
          ),

          // Top Search Bar
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Où allez-vous ?',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showProfileSwitcher(context),
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      radius: 18,
                      child: Icon(_getProfileIcon(activeProfile.type),
                        size: 18, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Buttons (Right)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildFloatingButton(LucideIcons.layers, () {}),
                const SizedBox(height: 12),
                _buildFloatingButton(LucideIcons.crosshair, () {
                  // Center on user
                }),
              ],
            ),
          ),

          // Bottom Sheet Handle (Indicator)
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => _showWeatherDetails(context),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _BottomWeatherIndicator(weather: parisWeather),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildFloatingButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      child: Icon(icon),
    );
  }

  IconData _getProfileIcon(ProfileType type) {
    switch (type) {
      case ProfileType.cyclist: return LucideIcons.bike;
      case ProfileType.hiker: return LucideIcons.footprints;
      case ProfileType.driver: return LucideIcons.car;
      default: return LucideIcons.user;
    }
  }

  void _showProfileSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ProfileSwitcher(),
    );
  }

  void _showWeatherDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Météo détaillée', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            WeatherTimeline(
              conditions: List.generate(10, (i) => WeatherCondition(
                temperature: 18.0 + i,
                precipitation: 0.0,
                windSpeed: 10.0 + i,
                windDirection: 0.0,
                weatherCode: i % 3 == 0 ? 0 : (i % 3 == 1 ? 2 : 61),
                timestamp: DateTime.now().add(Duration(minutes: i * 30)),
              )),
            ),
            const SizedBox(height: 24),
            const Text('Prévisions 7 jours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Add more detailed info here
          ],
        ),
      ),
    );
  }
}

class _BottomWeatherIndicator extends StatelessWidget {
  final AsyncValue<WeatherCondition> weather;

  const _BottomWeatherIndicator({required this.weather});

  @override
  Widget build(BuildContext context) {
    return weather.when(
      data: (w) {
        final icon = _iconForCode(w.weatherCode);
        final subtitle = '${w.temperature.round()}°C • Vent ${w.windSpeed.round()} km/h';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(icon, color: Colors.orange, size: 32),
          ],
        );
      },
      loading: () => const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Chargement…', style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      error: (err, st) {
        final msg = err is AppFailure ? err.message : 'Météo indisponible';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Paris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(msg, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 28),
          ],
        );
      },
    );
  }

  IconData _iconForCode(int code) {
    if (code == 0) return LucideIcons.sun;
    if (code < 3) return LucideIcons.cloudSun;
    if (code < 50) return LucideIcons.cloud;
    if (code < 70) return LucideIcons.cloudRain;
    return LucideIcons.cloudLightning;
  }
}
