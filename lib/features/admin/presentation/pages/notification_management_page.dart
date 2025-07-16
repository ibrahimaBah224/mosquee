import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  State<NotificationManagementPage> createState() =>
      _NotificationManagementPageState();
}

class _NotificationManagementPageState extends State<NotificationManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers pour l'envoi de notifications
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedTopic = NotificationService.TOPIC_ALL_USERS;
  bool _isLoading = false;

  // Historique des notifications
  List<NotificationHistoryItem> _history = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotificationHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Charge l'historique des notifications
  Future<void> _loadNotificationHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await NotificationService().getNotificationHistory();
      setState(() => _history = history);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur chargement historique: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  /// Envoie une notification personnalisée
  Future<void> _sendCustomNotification() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await NotificationService().sendNotificationToTopic(
        topic: _selectedTopic,
        title: _titleController.text.trim(),
        body: _messageController.text.trim(),
        type: NotificationType.announcement,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notification envoyée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _titleController.clear();
      _messageController.clear();

      // Reload history
      _loadNotificationHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Notifications'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.send), text: 'Envoyer'),
            Tab(icon: Icon(Icons.history), text: 'Historique'),
            Tab(icon: Icon(Icons.settings), text: 'Paramètres'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendNotificationTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  /// Onglet pour envoyer des notifications
  Widget _buildSendNotificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Notification rapide
          _buildQuickNotificationsSection(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // Section Notification personnalisée
          _buildCustomNotificationSection(),
        ],
      ),
    );
  }

  /// Section des notifications rapides
  Widget _buildQuickNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚡ Notifications Rapides',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildQuickNotificationCard(
              icon: Icons.access_time,
              title: 'Horaires Prière',
              subtitle: 'Horaires modifiés',
              color: Colors.blue,
              onTap: () => _sendQuickNotification(
                'Horaires de prière modifiés',
                'Les nouveaux horaires de prière sont maintenant disponibles',
                NotificationService.TOPIC_PRAYER_TIMES,
              ),
            ),
            _buildQuickNotificationCard(
              icon: Icons.event,
              title: 'Nouvel Événement',
              subtitle: 'Cours/Conférence',
              color: Colors.green,
              onTap: () => _sendQuickNotification(
                'Nouvel événement',
                'Un nouvel événement a été ajouté au calendrier',
                NotificationService.TOPIC_EVENTS,
              ),
            ),
            _buildQuickNotificationCard(
              icon: Icons.volunteer_activism,
              title: 'Appel aux Dons',
              subtitle: 'Nouvelle campagne',
              color: Colors.orange,
              onTap: () => _sendQuickNotification(
                'Nouvelle campagne de don',
                'Une nouvelle campagne de collecte a été lancée',
                NotificationService.TOPIC_DONATIONS,
              ),
            ),
            _buildQuickNotificationCard(
              icon: Icons.announcement,
              title: 'Annonce Générale',
              subtitle: 'Info importante',
              color: Colors.red,
              onTap: () => _sendQuickNotification(
                'Annonce importante',
                'Une information importante vous attend',
                NotificationService.TOPIC_ALL_USERS,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card pour notification rapide
  Widget _buildQuickNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section de notification personnalisée
  Widget _buildCustomNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✏️ Notification Personnalisée',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Sélection du topic
        DropdownButtonFormField<String>(
          value: _selectedTopic,
          decoration: const InputDecoration(
            labelText: 'Destinataires',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.group),
          ),
          items: [
            DropdownMenuItem(
              value: NotificationService.TOPIC_ALL_USERS,
              child: const Text('📱 Tous les utilisateurs'),
            ),
            DropdownMenuItem(
              value: NotificationService.TOPIC_PRAYER_TIMES,
              child: const Text('🕌 Abonnés aux prières'),
            ),
            DropdownMenuItem(
              value: NotificationService.TOPIC_EVENTS,
              child: const Text('📅 Abonnés aux événements'),
            ),
            DropdownMenuItem(
              value: NotificationService.TOPIC_DONATIONS,
              child: const Text('💰 Abonnés aux dons'),
            ),
            DropdownMenuItem(
              value: NotificationService.TOPIC_STAFF,
              child: const Text('👥 Équipe mosquée'),
            ),
          ],
          onChanged: (value) => setState(() => _selectedTopic = value!),
        ),

        const SizedBox(height: 16),

        // Titre
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Titre de la notification',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          maxLength: 50,
        ),

        const SizedBox(height: 16),

        // Message
        TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.message),
          ),
          maxLines: 3,
          maxLength: 200,
        ),

        const SizedBox(height: 24),

        // Bouton d'envoi
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _sendCustomNotification,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label:
                Text(_isLoading ? 'Envoi en cours...' : 'Envoyer Notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Onglet historique
  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune notification envoyée',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotificationHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return _buildHistoryItem(item);
        },
      ),
    );
  }

  /// Item de l'historique
  Widget _buildHistoryItem(NotificationHistoryItem item) {
    final typeIcon = _getTypeIcon(item.type);
    final topicName = _getTopicName(item.topic);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          child: Icon(typeIcon, color: AppTheme.primaryGreen),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.body),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  topicName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(item.sentAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  /// Onglet paramètres
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Paramètres des Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.info,
              title: 'Token FCM',
              subtitle: 'Identifiant unique de cet appareil',
              onTap: _showFCMToken,
            ),
            _buildSettingsTile(
              icon: Icons.refresh,
              title: 'Actualiser historique',
              subtitle: 'Recharger la liste des notifications',
              onTap: _loadNotificationHistory,
            ),
            _buildSettingsTile(
              icon: Icons.help,
              title: 'Guide d\'utilisation',
              subtitle: 'Comment utiliser les notifications',
              onTap: _showUsageGuide,
            ),
          ]),
        ],
      ),
    );
  }

  /// Card des paramètres
  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  /// Tile des paramètres
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Envoie une notification rapide
  Future<void> _sendQuickNotification(
      String title, String body, String topic) async {
    try {
      await NotificationService().sendNotificationToTopic(
        topic: topic,
        title: title,
        body: body,
        type: NotificationType.announcement,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notification envoyée !'),
          backgroundColor: Colors.green,
        ),
      );

      _loadNotificationHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur: ${e.toString()}')),
      );
    }
  }

  /// Affiche le token FCM
  Future<void> _showFCMToken() async {
    final token = await NotificationService().getFCMToken();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Token FCM'),
        content: SelectableText(token ?? 'Token non disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Affiche le guide d'utilisation
  void _showUsageGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guide d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text('''
🚀 Notifications Rapides:
• Utilisez les boutons pour envoyer des notifications prédéfinies
• Chaque type cible automatiquement les bons utilisateurs

✏️ Notifications Personnalisées:
• Choisissez vos destinataires
• Rédigez un titre et un message
• Le système envoie automatiquement à tous les abonnés

📱 Topics disponibles:
• Tous les utilisateurs: Notifications générales
• Prières: Changements d'horaires
• Événements: Nouveaux événements
• Dons: Campagnes de collecte
• Équipe: Messages internes

💡 Conseils:
• Gardez les messages courts et clairs
• Utilisez des émojis pour attirer l'attention
• Vérifiez l'historique pour éviter les doublons
          '''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  /// Obtient l'icône selon le type
  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.prayerTimes:
        return Icons.access_time;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.donation:
        return Icons.volunteer_activism;
      case NotificationType.staff:
        return Icons.group;
      case NotificationType.announcement:
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }

  /// Obtient le nom du topic
  String _getTopicName(String topic) {
    switch (topic) {
      case NotificationService.TOPIC_ALL_USERS:
        return 'Tous les utilisateurs';
      case NotificationService.TOPIC_PRAYER_TIMES:
        return 'Abonnés aux prières';
      case NotificationService.TOPIC_EVENTS:
        return 'Abonnés aux événements';
      case NotificationService.TOPIC_DONATIONS:
        return 'Abonnés aux dons';
      case NotificationService.TOPIC_STAFF:
        return 'Équipe mosquée';
      default:
        return topic;
    }
  }

  /// Formate la date et heure
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return 'Aujourd\'hui ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
