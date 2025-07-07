import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/mosque_service.dart';
import '../services/imam_service.dart';
import '../services/muezzin_service.dart';
import '../models/prayer_time.dart';
import '../models/event.dart';
import '../models/news.dart';
import '../models/book.dart';
import '../models/donation.dart';

class FirebaseInitializer {
  static final FirestoreService _firestoreService = FirestoreService();
  static const _uuid = Uuid();

  /// Initialise Firebase avec des données d'exemple
  static Future<void> initializeSampleData() async {
    try {
      await _initializeMosqueInfo();
      await _initializeImams();
      await _initializeMuezzins();
      await _createSamplePrayerConfiguration();
      await _createSamplePrayerTimes();
      await _createSampleEvents();
      await _createSampleNews();
      await _createSampleBooks();
      await _createSampleDonationCampaigns();

      print('✅ Données d\'exemple créées avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création des données d\'exemple: $e');
    }
  }

  static Future<void> _initializeMosqueInfo() async {
    final mosqueService = MosqueService();
    await mosqueService.initializeDefaultData();
    print('✅ Informations de la mosquée initialisées');
  }

  static Future<void> _initializeImams() async {
    final imamService = ImamService();
    await imamService.initializeSampleImams();
    print('✅ Imams initialisés');
  }

  static Future<void> _initializeMuezzins() async {
    final muezzinService = MuezzinService();
    await muezzinService.initializeSampleMuezzins();
    print('✅ Muezzins initialisés');
  }

  static Future<void> _createSamplePrayerConfiguration() async {
    final config = PrayerConfiguration(
      id: 'main',
      mosqueName: 'Mosquée Elhadj Daouda',
      latitude: 9.5380, // Conakry
      longitude: -13.6773, // Conakry
      timezone: 'Africa/Conakry',
      calculationMethod: 'MECCA',
      adjustments: {
        'fajr': 0,
        'dhuhr': 0,
        'asr': 0,
        'maghrib': 0,
        'isha': 0,
      },
      automaticCalculation: true,
      updatedAt: DateTime.now(),
    );

    await _firestoreService.updatePrayerConfiguration(config);
  }

  static Future<void> _createSamplePrayerTimes() async {
    final today = DateTime.now();
    final prayerTimes = [
      PrayerTime(
        id: _uuid.v4(),
        name: 'Fajr',
        nameArabic: 'الفجر',
        time: '05:30',
        isEnabled: true,
        date: today,
        adjustmentMinutes: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PrayerTime(
        id: _uuid.v4(),
        name: 'Dhuhr',
        nameArabic: 'الظهر',
        time: '12:45',
        isEnabled: true,
        date: today,
        adjustmentMinutes: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PrayerTime(
        id: _uuid.v4(),
        name: 'Asr',
        nameArabic: 'العصر',
        time: '15:30',
        isEnabled: true,
        date: today,
        adjustmentMinutes: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PrayerTime(
        id: _uuid.v4(),
        name: 'Maghrib',
        nameArabic: 'المغرب',
        time: '18:15',
        isEnabled: true,
        date: today,
        adjustmentMinutes: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PrayerTime(
        id: _uuid.v4(),
        name: 'Isha',
        nameArabic: 'العشاء',
        time: '20:00',
        isEnabled: true,
        date: today,
        adjustmentMinutes: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await _firestoreService.updatePrayerTimes(prayerTimes);
  }

  static Future<void> _createSampleEvents() async {
    final events = [
      Event(
        id: _uuid.v4(),
        title: 'Cours de Coran pour débutants',
        description:
            'Apprentissage des bases de la lecture du Coran avec Tajweed. Cours adapté aux débutants de tous âges.',
        category: EventCategory.educational,
        status: EventStatus.published,
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 2)),
        location: 'Salle d\'étude - 1er étage',
        maxParticipants: 20,
        currentParticipants: 12,
        requiresRegistration: true,
        organizer: 'Imam Ahmed',
        tags: ['Coran', 'Education', 'Débutants'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      ),
      Event(
        id: _uuid.v4(),
        title: 'Iftar communautaire',
        description:
            'Partageons ensemble la rupture du jeûne dans une ambiance fraternelle.',
        category: EventCategory.community,
        status: EventStatus.published,
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 3, hours: 3)),
        location: 'Grande salle de prière',
        maxParticipants: 100,
        currentParticipants: 45,
        requiresRegistration: true,
        organizer: 'Comité des activités',
        tags: ['Iftar', 'Communauté', 'Ramadan'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      ),
      Event(
        id: _uuid.v4(),
        title: 'Collecte de fonds pour la rénovation',
        description:
            'Événement de collecte de fonds pour la rénovation de la mosquée.',
        category: EventCategory.fundraising,
        status: EventStatus.published,
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 14, hours: 4)),
        location: 'Cour de la mosquée',
        maxParticipants: 200,
        currentParticipants: 78,
        requiresRegistration: false,
        organizer: 'Bureau de la mosquée',
        tags: ['Collecte', 'Rénovation', 'Communauté'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      ),
    ];

    for (final event in events) {
      await _firestoreService.createEvent(event);
    }
  }

  static Future<void> _createSampleNews() async {
    final newsList = [
      News(
        id: _uuid.v4(),
        title: 'Nouvelle bibliothèque islamique disponible',
        content: '''
        Nous avons le plaisir d\'annoncer l\'ouverture de notre nouvelle bibliothèque islamique numérique.
        
        Cette bibliothèque contient plus de 100 ouvrages en français et en arabe, couvrant différents domaines :
        - Coran et Tafsir
        - Hadith et Sunnah
        - Fiqh (jurisprudence islamique)
        - Seerah (biographie du Prophète)
        - Histoire islamique
        
        Tous les livres sont disponibles gratuitement pour consultation et téléchargement.
        ''',
        excerpt:
            'Découvrez notre nouvelle bibliothèque islamique numérique avec plus de 100 ouvrages gratuits.',
        category: NewsCategory.announcement,
        status: NewsStatus.published,
        tags: ['Bibliothèque', 'Livres', 'Éducation'],
        authorId: 'admin',
        authorName: 'Administration',
        isPinned: true,
        allowComments: true,
        viewCount: 45,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      News(
        id: _uuid.v4(),
        title: 'Nouveaux horaires de prière',
        content: '''
        En raison du changement d\'heure, nous avons mis à jour les horaires de prière.
        
        Les nouveaux horaires sont effectifs à partir d\'aujourd\'hui.
        Nous vous rappelons que vous pouvez consulter les horaires quotidiens directement dans l\'application.
        
        Qu\'Allah accepte vos prières.
        ''',
        excerpt:
            'Mise à jour des horaires de prière suite au changement d\'heure.',
        category: NewsCategory.religious,
        status: NewsStatus.published,
        tags: ['Prière', 'Horaires'],
        authorId: 'admin',
        authorName: 'Imam Ahmed',
        isPinned: false,
        allowComments: true,
        viewCount: 89,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      News(
        id: _uuid.v4(),
        title: 'Collecte réussie pour les familles nécessiteuses',
        content: '''
        Grâce à votre générosité, nous avons pu collecter 5000€ pour venir en aide aux familles nécessiteuses de notre communauté.
        
        Cette somme permettra de :
        - Distribuer des colis alimentaires
        - Aider au paiement de factures urgentes
        - Soutenir l\'éducation des enfants
        
        Qu\'Allah vous récompense pour votre générosité.
        ''',
        excerpt:
            'Succès de la collecte pour les familles nécessiteuses avec 5000€ récoltés.',
        category: NewsCategory.community,
        status: NewsStatus.published,
        tags: ['Collecte', 'Solidarité', 'Communauté'],
        authorId: 'admin',
        authorName: 'Comité social',
        isPinned: false,
        allowComments: true,
        viewCount: 67,
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];

    for (final news in newsList) {
      await _firestoreService.createNews(news);
    }
  }

  static Future<void> _createSampleBooks() async {
    final books = [
      Book(
        id: _uuid.v4(),
        title: 'Les 40 Hadiths de l\'Imam An-Nawawi',
        titleArabic: 'الأربعون النووية',
        author: 'Imam An-Nawawi',
        authorArabic: 'الإمام النووي',
        description:
            'Une collection des hadiths les plus importants pour comprendre l\'islam.',
        category: BookCategory.hadith,
        type: BookType.pdf,
        status: BookStatus.available,
        language: 'fr',
        isPublic: true,
        rating: 4.8,
        ratingCount: 24,
        publishedDate: DateTime(1270), // 13ème siècle
        addedAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        addedBy: 'admin',
      ),
      Book(
        id: _uuid.v4(),
        title: 'La Citadelle du Musulman',
        titleArabic: 'حصن المسلم',
        author: 'Saïd Ibn Ali Ibn Wahf Al-Qahtânî',
        authorArabic: 'سعيد بن علي بن وهف القحطاني',
        description:
            'Recueil d\'invocations tirées du Coran et de la Sunnah authentique.',
        category: BookCategory.general,
        type: BookType.pdf,
        status: BookStatus.available,
        pageCount: 256,
        language: 'fr',
        isPublic: true,
        rating: 4.9,
        ratingCount: 31,
        publishedDate: DateTime(1994),
        addedAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        addedBy: 'admin',
      ),
      Book(
        id: _uuid.v4(),
        title: 'Récitation du Coran - Sourate Al-Fatiha',
        titleArabic: 'تلاوة سورة الفاتحة',
        author: 'Cheikh Abdul Rahman Al-Sudais',
        authorArabic: 'الشيخ عبد الرحمن السديس',
        description:
            'Récitation de la sourate Al-Fatiha par le Cheikh Abdul Rahman Al-Sudais.',
        category: BookCategory.quran,
        type: BookType.audio,
        status: BookStatus.available,
        duration: '2:15',
        language: 'ar',
        isPublic: true,
        downloadCount: 156,
        rating: 5.0,
        ratingCount: 67,
        publishedDate: DateTime(2010),
        addedAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        addedBy: 'admin',
      ),
    ];

    for (final book in books) {
      await _firestoreService.createBook(book);
    }
  }

  static Future<void> _createSampleDonationCampaigns() async {
    final campaigns = [
      DonationCampaign(
        id: _uuid.v4(),
        title: 'Rénovation de la mosquée',
        description: '''
        Notre mosquée a besoin de votre aide pour les travaux de rénovation.
        
        Les fonds serviront à :
        - Réfection de la toiture
        - Rénovation des sanitaires
        - Amélioration du système de chauffage
        - Embellissement des espaces de prière
        ''',
        targetAmount: 50000.0,
        currentAmount: 23500.0,
        currency: 'EUR',
        type: DonationType.masjid,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        isActive: true,
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      DonationCampaign(
        id: _uuid.v4(),
        title: 'Aide aux familles nécessiteuses',
        description: '''
        Soutenez les familles de notre communauté qui traversent des difficultés.
        
        Vos dons permettront :
        - Distribution de colis alimentaires
        - Aide au paiement des factures
        - Soutien pour l\'éducation des enfants
        - Assistance médicale d\'urgence
        ''',
        targetAmount: 15000.0,
        currentAmount: 8750.0,
        currency: 'EUR',
        type: DonationType.charity,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        isActive: true,
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];

    // Note: Ces méthodes ne sont pas encore implémentées dans FirestoreService
    // await _firestoreService.createDonationCampaign(campaign);
    print('Campagnes de dons créées (à implémenter)');
  }
}
