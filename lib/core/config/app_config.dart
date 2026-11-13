// lib/core/config/app_config.dart
// Unica fonte di verità per URL, endpoint, token e costanti fisse.
// Nome e sesso dei partner NON stanno qui: vengono dal profilo locale
// (vedi lib/features/profile/).

abstract final class AppConfig {
  // ---- App ----
  static const appName = 'Temperino';
  static const appVersion =
      '2.0.0'; // tenere allineato a `version:` in pubspec.yaml
  static const androidPackage = 'com.strifelab.temperino';

  // ---- Backend (Strapi v4, lo stesso dell'app attuale) ----
  static const baseUrl = 'https://strapi.andreacorriga.com/api/';
  static const apiToken =
      '6ea9ef5fe408811f06611b7cc223978b4645711591eb551dc5797a4d588d606f9071dcfceba15b178e7bdd34f3fe084e52cf097482d5771339735febca9b7189d19a2f8e18dcf7bad4a7eaa2f18168d10285dbb77cf838a31f6014602349b0c471b77d3deaab49f40410025f26b16f1b6ef9855559569dd4924ea03c51d7d2b7';
  static const requestTimeout = Duration(seconds: 20);

  // ---- Endpoint (path relativi a baseUrl) ----
  static const sexualActivitiesPath = 'sexual-activities';
  static const masturbationsPath = 'masturbations';

  // ---- Paginazione (Strapi v4: pagination[page], pagination[pageSize]) ----
  static const pageSize = 100;
  static const paginationPageParam = 'pagination[page]';
  static const paginationPageSizeParam = 'pagination[pageSize]';

  // ---- Query (Strapi v4: filters, sort) ----
  // Raw string: `$` non deve essere interpolato da Dart.
  static const dateField = 'date';
  static const filterDateGteParam = r'filters[date][$gte]';
  static const filterDateLteParam = r'filters[date][$lte]';
  static const sortQueryParam = 'sort';
  static const sortParam = 'date:desc';

  // ---- Concorrenza ----
  /// Massimo numero di richieste parallele per il confronto anni.
  static const maxParallelRequests = 5;

  // ---- Dominio ----
  static const startYear = 2024;

  // Valore API del partner -> chiave del profilo. Il nome e il sesso
  // vengono dal profilo locale, non da qui.
  static const partnerApiValues = ['A', 'B']; // A = partner 1, B = partner 2
  static const partnerAvatarA = 'assets/images/temperinoA.jpg';
  static const partnerAvatarB = 'assets/images/temperinoD.jpg';
  static const activitiesImage = 'assets/images/sexual-activities.jpg';

  // Etichetta del conteggio masturbazioni per sesso del partner
  static const masturbationLabelMale = 'Seghe';
  static const masturbationLabelFemale = 'Ditalini';

  // Etichette del sesso nel profilo
  static const genderLabelMale = 'Maschio';
  static const genderLabelFemale = 'Femmina';

  // Campo API -> etichetta italiana delle pratiche (B14: un solo nome
  // per pratica, uguale in form e statistiche).
  static const practiceLabels = <String, String>{
    'sex': 'Sesso',
    'blowjob': 'Pompino',
    'handjob': 'Sega',
    'anal': 'Anal',
    'fingering': 'Ditalino',
    'lick': 'Leccata',
    'tits_fuck': 'Spagnola',
  };

  // Valore API -> etichetta italiana (le 12 zone del campo cumshot)
  static const cumshotLabels = <String, String>{
    'mouth': 'Bocca',
    'butts': 'Chiappe',
    'ass': 'Culo',
    'face': 'Faccia',
    'hips': 'Fianchi',
    'pussy-inside': 'Figa (dentro)',
    'pussy-condom': 'Figa (ghindolo)',
    'belly': 'Pancia',
    'feet': 'Piedi',
    'back': 'Schiena',
    'tits': 'Tette',
    'none': 'Niente (no sborrata)',
  };

  // ---- Chiavi shared_preferences ----
  static const prefOnboarded = 'profile.onboarded';
  static const prefPartnerAName = 'partner.a.name';
  static const prefPartnerAGender = 'partner.a.gender';
  static const prefPartnerBName = 'partner.b.name';
  static const prefPartnerBGender = 'partner.b.gender';
  static const prefSelectedYear = 'settings.year';
  static const prefThemeMode = 'settings.themeMode';
  static const prefListLayout = 'settings.listLayout';

  // ---- Validazione profilo ----
  static const partnerNameMaxLength = 30;
}
