import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Features Imports
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/prayer/presentation/pages/prayer_times_page.dart';
import '../../features/prayer/presentation/pages/qibla_compass_page.dart';
import '../../features/donations/presentation/pages/donations_page.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';

// Admin Pages
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/admin/presentation/pages/prayer_management_page.dart';
import '../../features/admin/presentation/pages/event_management_page.dart';
import '../../features/admin/presentation/pages/firebase_setup_page.dart';
import '../../features/admin/presentation/pages/mosque_settings_page.dart';
import '../../features/admin/presentation/pages/imam_management_page.dart';
import '../../features/admin/presentation/pages/muezzin_management_page.dart';
import '../../features/admin/presentation/pages/news_management_page.dart';
import '../../features/admin/presentation/pages/add_event_page.dart';

// Shell Navigation
import '../widgets/main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Authentication Routes
      GoRoute(path: '/auth', redirect: (context, state) => '/auth/login'),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Admin Routes (without shell navigation)
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/prayers',
        name: 'adminPrayers',
        builder: (context, state) => const PrayerManagementPage(),
      ),
      GoRoute(
        path: '/admin/events',
        name: 'adminEvents',
        builder: (context, state) => const EventManagementPage(),
      ),
      GoRoute(
        path: '/admin/firebase-setup',
        name: 'firebaseSetup',
        builder: (context, state) => const FirebaseSetupPage(),
      ),
      GoRoute(
        path: '/admin/mosque-settings',
        name: 'mosqueSettings',
        builder: (context, state) => const MosqueSettingsPage(),
      ),
      GoRoute(
        path: '/admin/imams',
        name: 'adminImams',
        builder: (context, state) => const ImamManagementPage(),
      ),
      GoRoute(
        path: '/admin/muezzins',
        name: 'adminMuezzins',
        builder: (context, state) => const MuezzinManagementPage(),
      ),

      // Routes pour l'ajout de contenu
      GoRoute(
        path: '/admin/events/create',
        name: 'addEvent',
        builder: (context, state) => const AddEventPage(),
      ),

      // Routes temporaires pour les pages non créées
      GoRoute(
        path: '/admin/news',
        name: 'adminNews',
        builder: (context, state) => const NewsManagementPage(),
      ),

      GoRoute(
        path: '/admin/news/create',
        name: 'addNews',
        builder: (context, state) => const TempAddNewsPage(),
      ),

      GoRoute(
        path: '/admin/books',
        name: 'adminBooks',
        builder: (context, state) => const TempBookManagementPage(),
      ),

      GoRoute(
        path: '/admin/books/create',
        name: 'addBook',
        builder: (context, state) => const TempAddBookPage(),
      ),

      GoRoute(
        path: '/admin/donations',
        name: 'adminDonations',
        builder: (context, state) => const TempDonationManagementPage(),
      ),

      GoRoute(
        path: '/admin/donations/create',
        name: 'addDonationCampaign',
        builder: (context, state) => const TempAddDonationPage(),
      ),

      GoRoute(
        path: '/admin/users',
        name: 'adminUsers',
        builder: (context, state) => const TempUserManagementPage(),
      ),

      // Main Shell avec Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),

          // Prayer Times
          GoRoute(
            path: '/prayer',
            name: 'prayer',
            builder: (context, state) => const PrayerTimesPage(),
          ),

          // Donations
          GoRoute(
            path: '/donations',
            name: 'donations',
            builder: (context, state) => const DonationsPage(),
          ),

          // Events
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsPage(),
            routes: [
              // Event Details
              GoRoute(
                path: 'detail/:eventId',
                name: 'eventDetail',
                builder: (context, state) {
                  final eventId = state.pathParameters['eventId']!;
                  return EventDetailPage(eventId: eventId);
                },
              ),
            ],
          ),

          // News
          GoRoute(
            path: '/news',
            name: 'news',
            builder: (context, state) => const NewsPage(),
            routes: [
              // News Article Detail
              GoRoute(
                path: 'article/:articleId',
                name: 'newsDetail',
                builder: (context, state) {
                  final articleId = state.pathParameters['articleId']!;
                  return NewsDetailPage(articleId: articleId);
                },
              ),
            ],
          ),

          // Library
          GoRoute(
            path: '/library',
            name: 'library',
            builder: (context, state) => const LibraryPage(),
            routes: [
              // Book Detail
              GoRoute(
                path: 'book/:bookId',
                name: 'bookDetail',
                builder: (context, state) {
                  final bookId = state.pathParameters['bookId']!;
                  return BookDetailPage(bookId: bookId);
                },
              ),
              // Audio Books
              GoRoute(
                path: 'audio',
                name: 'audioBooks',
                builder: (context, state) => const AudioBooksPage(),
              ),
            ],
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              // Edit Profile
              GoRoute(
                path: 'edit',
                name: 'editProfile',
                builder: (context, state) => const EditProfilePage(),
              ),
              // Prayer History
              GoRoute(
                path: 'prayer-history',
                name: 'prayerHistory',
                builder: (context, state) => const PrayerHistoryPage(),
              ),
              // Donation History
              GoRoute(
                path: 'donation-history',
                name: 'donationHistory',
                builder: (context, state) => const DonationHistoryPage(),
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              // Notification Settings
              GoRoute(
                path: 'notifications',
                name: 'notificationSettings',
                builder: (context, state) => const NotificationSettingsPage(),
              ),
              // Language Settings
              GoRoute(
                path: 'language',
                name: 'languageSettings',
                builder: (context, state) => const LanguageSettingsPage(),
              ),
              // About
              GoRoute(
                path: 'about',
                name: 'about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Pages (sans bottom navigation)
      GoRoute(
        path: '/qibla',
        name: 'qibla',
        builder: (context, state) => const QiblaCompassPage(),
      ),

      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const IslamicCalendarPage(),
      ),

      GoRoute(
        path: '/donation/payment',
        name: 'donationPayment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DonationPaymentPage(
            amount: extra?['amount'] ?? 0.0,
            category: extra?['category'] ?? '',
            method: extra?['method'] ?? '',
          );
        },
      ),

      GoRoute(
        path: '/event/register/:eventId',
        name: 'eventRegister',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventRegistrationPage(eventId: eventId);
        },
      ),
    ],

    // Error Page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La page que vous cherchez n\'existe pas.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Pages supplémentaires à créer
class EventDetailPage extends StatelessWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de l\'événement')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Événement ID: $eventId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/event/register/$eventId'),
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final String articleId;

  const NewsDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: Center(child: Text('Article ID: $articleId')),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livre')),
      body: Center(child: Text('Livre ID: $bookId')),
    );
  }
}

class AudioBooksPage extends StatelessWidget {
  const AudioBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livres Audio')),
      body: const Center(child: Text('Livres Audio Islamiques')),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: const Center(child: Text('Édition du profil')),
    );
  }
}

class PrayerHistoryPage extends StatelessWidget {
  const PrayerHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des prières')),
      body: const Center(child: Text('Historique des prières')),
    );
  }
}

class DonationHistoryPage extends StatelessWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des dons')),
      body: const Center(child: Text('Historique des dons')),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Paramètres de notifications')),
    );
  }
}

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Langue')),
      body: const Center(child: Text('Paramètres de langue')),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: const Center(child: Text('À propos de l\'application')),
    );
  }
}

class IslamicCalendarPage extends StatelessWidget {
  const IslamicCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier Islamique')),
      body: const Center(child: Text('Calendrier Islamique complet')),
    );
  }
}

class DonationPaymentPage extends StatelessWidget {
  final double amount;
  final String category;
  final String method;

  const DonationPaymentPage({
    super.key,
    required this.amount,
    required this.category,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Montant: ${amount}€'),
            Text('Catégorie: $category'),
            Text('Méthode: $method'),
          ],
        ),
      ),
    );
  }
}

class EventRegistrationPage extends StatelessWidget {
  final String eventId;

  const EventRegistrationPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Center(child: Text('Inscription à l\'événement $eventId')),
    );
  }
}

// Pages temporaires pour l'administration
class TempNewsManagementPage extends StatelessWidget {
  const TempNewsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Actualités'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Gestion des Actualités',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Page en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TempAddNewsPage extends StatelessWidget {
  const TempAddNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Actualité'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Ajouter une Actualité',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Page en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TempBookManagementPage extends StatelessWidget {
  const TempBookManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de la Bibliothèque'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Gestion des Livres',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Page en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TempAddBookPage extends StatelessWidget {
  const TempAddBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Livre'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Ajouter un Livre',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Page en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TempDonationManagementPage extends StatelessWidget {
  const TempDonationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Dons'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Gestion des Campagnes de Dons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Page en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TempAddDonationPage extends StatelessWidget {
  const TempAddDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Campagne'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Créer une Campagne de Don',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Page en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TempUserManagementPage extends StatelessWidget {
  const TempUserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Gestion des Utilisateurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Page en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
