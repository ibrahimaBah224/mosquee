import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/user_profile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // En mode debug, autoriser l'accès admin sans authentification
        if (!kDebugMode && state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(
              child: Text('Accès non autorisé'),
            ),
          );
        }

        // Vérifier si l'utilisateur est admin (à implémenter avec le profil)
        return Scaffold(
          appBar: AppBar(
            title: const Text('Administration'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              if (kDebugMode)
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEBUG',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Configuration globale
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Utilisateurs',
                        value: '150',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Événements',
                        value: '25',
                        icon: Icons.event,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Actualités',
                        value: '42',
                        icon: Icons.article,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Livres',
                        value: '89',
                        icon: Icons.book,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Management Sections
                Text(
                  'Gestion du contenu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildManagementCard(
                      context,
                      title: 'Heures de Prière',
                      subtitle: 'Configurer les horaires',
                      icon: Icons.access_time,
                      color: Colors.teal,
                      onTap: () => context.go('/admin/prayers'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Événements',
                      subtitle: 'Gérer les événements',
                      icon: Icons.event,
                      color: Colors.green,
                      onTap: () => context.go('/admin/events'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Actualités',
                      subtitle: 'Publier des actualités',
                      icon: Icons.article,
                      color: Colors.orange,
                      onTap: () => context.go('/admin/news'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Bibliothèque',
                      subtitle: 'Gérer les livres',
                      icon: Icons.library_books,
                      color: Colors.purple,
                      onTap: () => context.go('/admin/books'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Dons',
                      subtitle: 'Campagnes de dons',
                      icon: Icons.monetization_on,
                      color: Colors.amber,
                      onTap: () => context.go('/admin/donations'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Utilisateurs',
                      subtitle: 'Gérer les utilisateurs',
                      icon: Icons.people,
                      color: Colors.blue,
                      onTap: () => context.go('/admin/users'),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'Mosquée',
                      subtitle: 'Configuration générale',
                      icon: Icons.mosque,
                      color: Colors.indigo,
                      onTap: () => context.go('/admin/mosque-settings'),
                    ),
                    _buildActionCard(
                      context,
                      'Imams',
                      'Gérer les Imams et leur hiérarchie',
                      Icons.people,
                      Colors.teal,
                      () => context.go('/admin/imams'),
                    ),
                    _buildActionCard(
                      context,
                      'Muezzins',
                      'Gérer les Muezzins et leurs horaires',
                      Icons.record_voice_over,
                      Colors.indigo,
                      () => context.go('/admin/muezzins'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickActionChip(
                      context,
                      label: 'Nouveau Événement',
                      icon: Icons.add_circle,
                      onTap: () => context.go('/admin/events/create'),
                    ),
                    _buildQuickActionChip(
                      context,
                      label: 'Nouvelle Actualité',
                      icon: Icons.add_circle,
                      onTap: () => context.go('/admin/news/create'),
                    ),
                    _buildQuickActionChip(
                      context,
                      label: 'Ajouter Livre',
                      icon: Icons.add_circle,
                      onTap: () => context.go('/admin/books/create'),
                    ),
                    _buildQuickActionChip(
                      context,
                      label: 'Campagne Don',
                      icon: Icons.add_circle,
                      onTap: () => context.go('/admin/donations/create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onPressed: onTap,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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
