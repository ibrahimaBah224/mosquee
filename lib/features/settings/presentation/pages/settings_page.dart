import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section Apparence
              _buildSectionTitle('Apparence'),
              _buildSettingsCard([
                _buildSwitchTile(
                  'Mode sombre',
                  'Thème sombre pour vos yeux',
                  Icons.dark_mode,
                  state.isDarkMode,
                  (value) => context.read<SettingsBloc>().add(ToggleTheme()),
                ),
                _buildDropdownTile(
                  'Langue',
                  'Choisir la langue de l\'application',
                  Icons.language,
                  state.language,
                  {'fr': 'Français', 'ar': 'العربية', 'en': 'English'},
                  (language) => context
                      .read<SettingsBloc>()
                      .add(ChangeLanguage(language: language!)),
                ),
              ]),

              const SizedBox(height: 24),

              // Section Notifications
              _buildSectionTitle('Notifications'),
              _buildSettingsCard([
                _buildSwitchTile(
                  'Notifications',
                  'Recevoir les notifications',
                  Icons.notifications,
                  state.notificationsEnabled,
                  (value) =>
                      context.read<SettingsBloc>().add(ToggleNotifications()),
                ),
                _buildSwitchTile(
                  'Rappels de prière',
                  'Notifications pour les prières',
                  Icons.access_time,
                  state.prayerRemindersEnabled,
                  (value) =>
                      context.read<SettingsBloc>().add(TogglePrayerReminders()),
                ),
              ]),

              const SizedBox(height: 24),

              // Section Prières
              _buildSectionTitle('Prières'),
              _buildSettingsCard([
                _buildListTile(
                  'Méthode de calcul',
                  'Ligue mondiale musulmane',
                  Icons.calculate,
                  () => _showCalculationMethodDialog(context),
                ),
                _buildListTile(
                  'École juridique',
                  'Shafi',
                  Icons.school,
                  () => _showMadhabDialog(context),
                ),
                _buildListTile(
                  'Ajustements',
                  'Personnaliser les horaires',
                  Icons.tune,
                  () => _showAdjustmentsDialog(context),
                ),
              ]),

              const SizedBox(height: 24),

              // Section Compte
              _buildSectionTitle('Compte'),
              _buildSettingsCard([
                _buildListTile(
                  'Profil',
                  'Gérer votre profil',
                  Icons.person,
                  () => Navigator.of(context).pushNamed('/profile'),
                ),
                _buildListTile(
                  'Historique des dons',
                  'Voir vos donations',
                  Icons.history,
                  () => Navigator.of(context).pushNamed('/donations'),
                ),
                _buildListTile(
                  'Sécurité',
                  'Mot de passe et sécurité',
                  Icons.security,
                  () => _showSecurityDialog(context),
                ),
              ]),

              const SizedBox(height: 24),

              // Section Information
              _buildSectionTitle('Information'),
              _buildSettingsCard([
                _buildListTile(
                  'À propos',
                  'Version 1.0.0',
                  Icons.info,
                  () => _showAboutDialog(context),
                ),
                _buildListTile(
                  'Politique de confidentialité',
                  'Consulter nos politiques',
                  Icons.privacy_tip,
                  () => _showPrivacyDialog(context),
                ),
                _buildListTile(
                  'Support',
                  'Contacter l\'équipe',
                  Icons.support,
                  () => _showSupportDialog(context),
                ),
              ]),

              const SizedBox(height: 24),

              // Bouton de déconnexion
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: const Color(0xFF2E7D32)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2E7D32),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String currentValue,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      trailing: DropdownButton<String>(
        value: currentValue,
        items: options.entries
            .map(
              (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
            )
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  void _showCalculationMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Méthode de calcul'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Ligue mondiale musulmane',
            'Société islamique d\'Amérique du Nord',
            'Université des sciences islamiques de Karachi',
            'Umm al-Qura, La Mecque',
            'Union des organisations islamiques de France',
          ]
              .map(
                (method) => RadioListTile<String>(
                  title: Text(method),
                  value: method,
                  groupValue: 'Ligue mondiale musulmane',
                  onChanged: (value) => Navigator.pop(context),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showMadhabDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('École juridique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Shafi', 'Hanafi', 'Maliki', 'Hanbali']
              .map(
                (madhab) => RadioListTile<String>(
                  title: Text(madhab),
                  value: madhab,
                  groupValue: 'Shafi',
                  onChanged: (value) => Navigator.pop(context),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustements des horaires'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Fajr: +2 minutes',
            'Dhuhr: 0 minutes',
            'Asr: -1 minute',
            'Maghrib: +1 minute',
            'Isha: +3 minutes',
          ].map((adj) => ListTile(title: Text(adj))).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sécurité'),
        content: const Text(
          'Fonctionnalité de sécurité à venir dans une prochaine mise à jour.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MOMED',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.mosque),
      children: [
        const Text('© 2024 MOMED'),
        const SizedBox(height: 8),
        const Text('Application mobile pour la mosquée Elhadj Daouda.'),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'Nous respectons votre vie privée. Vos données personnelles sont protégées et ne sont jamais partagées avec des tiers sans votre consentement explicite.',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('J\'ai compris'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('support@elhadj-daouda.org'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: const Text('+224 XX XX XX XX'),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/auth/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
