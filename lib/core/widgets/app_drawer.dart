import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header avec design islamique
          _buildDrawerHeader(context),

          // Menu principal
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),

                // Section Navigation Principale
                _buildSectionTitle('Navigation'),
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: 'Accueil',
                  subtitle: 'Page principale',
                  route: '/',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.mosque,
                  title: 'Horaires de Prière',
                  subtitle: 'Temps de prière quotidiens',
                  route: '/prayer',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.volunteer_activism,
                  title: 'Donations',
                  subtitle: 'Zakat, Sadaqah et dons',
                  route: '/donations',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.event,
                  title: 'Événements',
                  subtitle: 'Conférences et activités',
                  route: '/events',
                ),

                const Divider(height: 32),

                // Section Ressources
                _buildSectionTitle('Ressources'),
                _buildMenuItem(
                  context,
                  icon: Icons.library_books,
                  title: 'Bibliothèque',
                  subtitle: 'Livres et ressources islamiques',
                  route: '/library',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.article,
                  title: 'Actualités',
                  subtitle: 'Nouvelles et articles',
                  route: '/news',
                ),

                const Divider(height: 32),

                // Section Outils
                _buildSectionTitle('Outils Islamiques'),
                _buildMenuItem(
                  context,
                  icon: Icons.explore,
                  title: 'Direction Qibla',
                  subtitle: 'Boussole vers La Mecque',
                  route: '/qibla',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.calendar_month,
                  title: 'Calendrier Islamique',
                  subtitle: 'Dates importantes',
                  route: '/calendar',
                ),

                const Divider(height: 32),

                // Section Personnel
                _buildSectionTitle('Mon Compte'),
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: 'Mon Profil',
                  subtitle: 'Informations personnelles',
                  route: '/profile',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Paramètres',
                  subtitle: 'Configuration de l\'app',
                  route: '/settings',
                ),
              ],
            ),
          ),

          // Footer avec version et contact
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
            const Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern géométrique en arrière-plan
          Positioned.fill(
            child: CustomPaint(painter: _IslamicPatternPainter()),
          ),

          // Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo ou icône mosquée
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Nom de la mosquée
                  const Text(
                    'Mosquée Al-Nour',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Phrase islamique
                  Text(
                    'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Au nom d\'Allah, le Miséricordieux',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const Spacer(),

                  // Informations utilisateur
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ahmed Benali',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Membre actif',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    Color? iconColor,
  }) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final isSelected =
        currentLocation == route ||
        (route != '/' && currentLocation.startsWith(route));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : iconColor ?? Colors.grey[600],
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                )
                : null,
        onTap: () {
          Navigator.of(context).pop(); // Fermer le drawer
          if (!isSelected) {
            context.go(route);
          }
        },
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Boutons d'action rapide
          Row(
            children: [
              Expanded(
                child: _buildFooterButton(
                  context,
                  icon: Icons.help_outline,
                  label: 'Aide',
                  onTap: () => _showHelpDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFooterButton(
                  context,
                  icon: Icons.logout,
                  label: 'Déconnexion',
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Version et copyright
          Text(
            'Mosquée Al-Nour v1.0.0',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            '© 2024 - Développé avec ❤️',
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    Navigator.of(context).pop(); // Fermer le drawer
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Aide & Support'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfo(
                  Icons.email,
                  'Email',
                  'support@mosquee-alnour.fr',
                ),
                const SizedBox(height: 12),
                _buildContactInfo(
                  Icons.phone,
                  'Téléphone',
                  '+33 1 23 45 67 89',
                ),
                const SizedBox(height: 12),
                _buildContactInfo(
                  Icons.location_on,
                  'Adresse',
                  '123 Rue de la Paix, Paris',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/settings/about');
                },
                child: const Text('En savoir plus'),
              ),
            ],
          ),
    );
  }

  Widget _buildContactInfo(IconData icon, String title, String info) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(info, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Navigator.of(context).pop(); // Fermer le drawer
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/auth/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );
  }
}

// Custom Painter pour le pattern islamique
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.3;

    // Dessiner des cercles concentriques
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(Offset(centerX, centerY), radius * i / 3, paint);
    }

    // Dessiner des lignes radiales
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final startX = centerX + (radius * 0.3) * cos(angle);
      final startY = centerY + (radius * 0.3) * sin(angle);
      final endX = centerX + radius * cos(angle);
      final endY = centerY + radius * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
