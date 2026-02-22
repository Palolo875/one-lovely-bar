// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'WeatherNav';

  @override
  String get searchDestination => 'Où allez-vous ?';

  @override
  String get rainRadar => 'Radar précipitations';

  @override
  String get wind => 'Vent';

  @override
  String get temperature => 'Température';

  @override
  String get activeOverlays => 'Overlays actifs';

  @override
  String get pointsOfInterest => 'Points d\'intérêt';

  @override
  String get shelter => 'Abris';

  @override
  String get hut => 'Refuges';

  @override
  String get weatherStation => 'Stations météo';

  @override
  String get port => 'Ports';

  @override
  String get radius => 'Rayon';

  @override
  String get detailedWeather => 'Météo détaillée';

  @override
  String get centerTarget => 'Centre';

  @override
  String get max3Layers =>
      'Max 3 couches actives pour garder la carte lisible.';

  @override
  String get resetToProfile => 'Réinitialiser selon profil';

  @override
  String get showPois => 'Afficher les POIs';

  @override
  String get weatherLoading => 'Chargement...';

  @override
  String get weatherUnavailable => 'Météo indisponible';

  @override
  String get clearSky => 'Ciel clair';

  @override
  String get fewClouds => 'Peu nuageux';

  @override
  String get cloudy => 'Nuageux';

  @override
  String get rain => 'Pluie';

  @override
  String get thunderstorm => 'Orage';

  @override
  String get error => 'Erreur';
}
