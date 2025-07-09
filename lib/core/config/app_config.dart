class AppConfig {
  static const String appName = 'MOMED';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Application mobile pour la communauté musulmane';
  static const String packageName = 'com.mosquee.alnour';

  // API Configuration
  static const String baseUrl = 'https://api.mosquee-alnour.fr';
  static const String apiVersion = 'v1';
  static const String apiKey = 'your_api_key_here';

  // Firebase Configuration
  static const bool useFirebaseEmulator = false;
  static const String firestoreHost = 'localhost';
  static const int firestorePort = 8080;

  // Location Configuration (Conakry, Guinée)
  static const double defaultLatitude = 9.5380; // Conakry
  static const double defaultLongitude = -13.6773; // Conakry
  static const String defaultCity = 'Conakry';
  static const String defaultCountry = 'Guinée';
  static const String timezone = 'Africa/Conakry';

  // Prayer Times Configuration
  static const String calculationMethod =
      'MECCA'; // Méthode de calcul recommandée
  static const String madhab = 'SHAFI'; // École juridique
  static const int fajrAngle = 18;
  static const int maghribAngle = 0;
  static const int ishaAngle = 18;

  // Mosque Information
  static const String mosqueeName = 'Mosquée Elhadj Daouda';
  static const String mosqueeAddress = 'Quartier de Madina, Conakry, Guinée';
  static const String mosqueePhone = '+224 XX XX XX XX';
  static const String mosqueeEmail = 'contact@elhadj-daouda.org';
  static const String mosqueeWebsite = 'https://elhadj-daouda.org';

  // Social Media
  static const String facebookUrl =
      'https://facebook.com/mosquee-elhadj-daouda';
  static const String instagramUrl =
      'https://instagram.com/mosquee_elhadj_daouda';
  static const String youtubeUrl =
      'https://youtube.com/c/mosquee-elhadj-daouda';

  // Features Configuration
  static const bool enablePrayerNotifications = true;
  static const bool enableEventRegistration = true;
  static const bool enableDonations = true;
  static const bool enableLibrary = true;
  static const bool enableQiblaCompass = true;

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int animationDuration = 300; // milliseconds

  // Cache Configuration
  static const int cacheExpirationHours = 24;
  static const int maxCacheSize = 100; // MB

  // Environment
  static const bool isProduction = true;
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;

  // Firebase Configuration
  static const String firebaseProjectId = 'mosquee-alnour';
  static const String firebaseStorageBucket = 'mosquee-alnour.appspot.com';

  // Payment Configuration
  static const String stripePublishableKey = 'pk_test_your_stripe_key';

  // App Features
  static const bool enableNotifications = true;
  static const bool enablePrayerReminders = true;
  static const bool enableEvents = true;
  static const bool enableLiveStream = true;

  // Cache Duration (in hours)
  static const int prayerTimesCacheDuration = 24;
  static const int eventsCacheDuration = 6;
  static const int newsCacheDuration = 12;

  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'ddbhp3vpj';
  static const String cloudinaryApiKey = '947988289152758';
  static const String cloudinaryApiSecret = 'YpMAH-NKCXIbLqTEh3qztA4s5JU';
  static const bool cloudinaryEnabled = true;

  // Image Configuration
  static const int defaultImageWidth = 800;
  static const int defaultImageHeight = 600;
  static const int thumbnailSize = 150;
  static const String defaultImageFormat = 'webp';
}
