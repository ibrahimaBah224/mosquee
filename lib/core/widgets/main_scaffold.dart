import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    return Scaffold(
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(location),
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Prières'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Dons',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Événements'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Plus'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/prayer')) return 1;
    if (location.startsWith('/donations')) return 2;
    if (location.startsWith('/events')) return 3;
    if (location.startsWith('/news') ||
        location.startsWith('/library') ||
        location.startsWith('/profile') ||
        location.startsWith('/settings'))
      return 4;
    return 0; // Home
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/prayer');
        break;
      case 2:
        context.go('/donations');
        break;
      case 3:
        context.go('/events');
        break;
      case 4:
        _showMoreOptions(context);
        break;
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Plus d\'options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Options Grid
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    _buildMenuOption(
                      context,
                      icon: Icons.article,
                      label: 'Actualités',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/news');
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.library_books,
                      label: 'Bibliothèque',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/library');
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.person,
                      label: 'Profil',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/profile');
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.explore,
                      label: 'Qibla',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/qibla');
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.calendar_month,
                      label: 'Calendrier',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/calendar');
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.settings,
                      label: 'Paramètres',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/settings');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
