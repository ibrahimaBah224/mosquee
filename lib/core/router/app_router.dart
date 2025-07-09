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
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/staff/presentation/pages/imams_page.dart';
import '../../features/staff/presentation/pages/muezzins_page.dart';

// Admin Pages
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/admin/presentation/pages/prayer_management_page.dart';
import '../../features/admin/presentation/pages/event_management_page.dart';
import '../../features/admin/presentation/pages/firebase_setup_page.dart';
import '../../features/admin/presentation/pages/mosque_settings_page.dart';
import '../../features/admin/presentation/pages/imam_management_page.dart';
import '../../features/admin/presentation/pages/muezzin_management_page.dart';
import '../../features/admin/presentation/pages/add_event_page.dart';
import '../../features/admin/presentation/pages/cloudinary_settings_page.dart';
import '../../features/admin/presentation/pages/user_management_page.dart';
import '../../features/admin/presentation/pages/donation_management_page.dart';

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
        path: '/admin/login',
        name: 'adminLogin',
        builder: (context, state) => const AdminLoginPage(),
      ),
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
      GoRoute(
        path: '/admin/events/create',
        name: 'addEvent',
        builder: (context, state) => const AddEventPage(),
      ),
      GoRoute(
        path: '/admin/donations',
        name: 'adminDonations',
        builder: (context, state) => const DonationManagementPage(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'adminUsers',
        builder: (context, state) => const UserManagementPage(),
      ),
      GoRoute(
        path: '/admin/cloudinary',
        name: 'cloudinarySettings',
        builder: (context, state) => const CloudinarySettingsPage(),
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

          // Imams
          GoRoute(
            path: '/imams',
            name: 'imams',
            builder: (context, state) => const ImamsPage(),
          ),

          // Muezzins
          GoRoute(
            path: '/muezzins',
            name: 'muezzins',
            builder: (context, state) => const MuezzinsPage(),
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

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: const Center(child: Text('Page de modification du profil')),
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
      body: const Center(child: Text('Historique des donations')),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres de notification')),
      body: const Center(child: Text('Paramètres de notification')),
    );
  }
}

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres de langue')),
      body: const Center(child: Text('Paramètres de langue')),
    );
  }
}

class IslamicCalendarPage extends StatelessWidget {
  const IslamicCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier Islamique')),
      body: const Center(child: Text('Calendrier Islamique')),
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
            Text('Montant: $amount GNF'),
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
      appBar: AppBar(title: const Text('Inscription à l\'événement')),
      body: Center(child: Text('Inscription pour l\'événement: $eventId')),
    );
  }
}
