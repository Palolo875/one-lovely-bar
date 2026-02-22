import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'WeatherNav'**
  String get appTitle;

  /// No description provided for @searchDestination.
  ///
  /// In fr, this message translates to:
  /// **'Où allez-vous ?'**
  String get searchDestination;

  /// No description provided for @rainRadar.
  ///
  /// In fr, this message translates to:
  /// **'Radar précipitations'**
  String get rainRadar;

  /// No description provided for @wind.
  ///
  /// In fr, this message translates to:
  /// **'Vent'**
  String get wind;

  /// No description provided for @temperature.
  ///
  /// In fr, this message translates to:
  /// **'Température'**
  String get temperature;

  /// No description provided for @activeOverlays.
  ///
  /// In fr, this message translates to:
  /// **'Overlays actifs'**
  String get activeOverlays;

  /// No description provided for @pointsOfInterest.
  ///
  /// In fr, this message translates to:
  /// **'Points d\'intérêt'**
  String get pointsOfInterest;

  /// No description provided for @shelter.
  ///
  /// In fr, this message translates to:
  /// **'Abris'**
  String get shelter;

  /// No description provided for @hut.
  ///
  /// In fr, this message translates to:
  /// **'Refuges'**
  String get hut;

  /// No description provided for @weatherStation.
  ///
  /// In fr, this message translates to:
  /// **'Stations météo'**
  String get weatherStation;

  /// No description provided for @port.
  ///
  /// In fr, this message translates to:
  /// **'Ports'**
  String get port;

  /// No description provided for @radius.
  ///
  /// In fr, this message translates to:
  /// **'Rayon'**
  String get radius;

  /// No description provided for @detailedWeather.
  ///
  /// In fr, this message translates to:
  /// **'Météo détaillée'**
  String get detailedWeather;

  /// No description provided for @centerTarget.
  ///
  /// In fr, this message translates to:
  /// **'Centre'**
  String get centerTarget;

  /// No description provided for @max3Layers.
  ///
  /// In fr, this message translates to:
  /// **'Max 3 couches actives pour garder la carte lisible.'**
  String get max3Layers;

  /// No description provided for @resetToProfile.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser selon profil'**
  String get resetToProfile;

  /// No description provided for @showPois.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les POIs'**
  String get showPois;

  /// No description provided for @weatherLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get weatherLoading;

  /// No description provided for @weatherUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Météo indisponible'**
  String get weatherUnavailable;

  /// No description provided for @clearSky.
  ///
  /// In fr, this message translates to:
  /// **'Ciel clair'**
  String get clearSky;

  /// No description provided for @fewClouds.
  ///
  /// In fr, this message translates to:
  /// **'Peu nuageux'**
  String get fewClouds;

  /// No description provided for @cloudy.
  ///
  /// In fr, this message translates to:
  /// **'Nuageux'**
  String get cloudy;

  /// No description provided for @rain.
  ///
  /// In fr, this message translates to:
  /// **'Pluie'**
  String get rain;

  /// No description provided for @thunderstorm.
  ///
  /// In fr, this message translates to:
  /// **'Orage'**
  String get thunderstorm;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
