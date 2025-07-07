import 'package:flutter/material.dart';
import '../../../../core/utils/firebase_initializer.dart';

class FirebaseSetupPage extends StatefulWidget {
  const FirebaseSetupPage({super.key});

  @override
  State<FirebaseSetupPage> createState() => _FirebaseSetupPageState();
}

class _FirebaseSetupPageState extends State<FirebaseSetupPage> {
  bool _isInitializing = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Firebase'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 64,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 24),
            Text(
              'Configuration Firebase',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Cette page vous permet d\'initialiser votre base de données Firebase avec des données d\'exemple pour tester l\'application.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Données qui seront créées :',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const _DataItem(
                      icon: Icons.access_time,
                      title: 'Configuration des prières',
                      subtitle: 'Heures de prière et paramètres de la mosquée',
                    ),
                    const _DataItem(
                      icon: Icons.event,
                      title: 'Événements d\'exemple',
                      subtitle: '3 événements (cours, iftar, collecte)',
                    ),
                    const _DataItem(
                      icon: Icons.article,
                      title: 'Actualités',
                      subtitle: '3 articles d\'actualité de la mosquée',
                    ),
                    const _DataItem(
                      icon: Icons.library_books,
                      title: 'Bibliothèque islamique',
                      subtitle: '3 livres islamiques (PDF et audio)',
                    ),
                    const _DataItem(
                      icon: Icons.monetization_on,
                      title: 'Campagnes de dons',
                      subtitle: '2 campagnes (rénovation et aide sociale)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_status.isNotEmpty) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _status,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isInitializing ? null : _initializeFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _isInitializing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isInitializing
                    ? 'Initialisation en cours...'
                    : 'Initialiser les données Firebase',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Cette opération ne supprime pas les données existantes, elle ajoute uniquement de nouvelles données d\'exemple.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeFirebase() async {
    setState(() {
      _isInitializing = true;
      _status = '';
    });

    try {
      await FirebaseInitializer.initializeSampleData();

      setState(() {
        _isInitializing = false;
        _status =
            'Données d\'exemple créées avec succès ! Vous pouvez maintenant naviguer dans l\'application.';
      });

      // Afficher un dialog de succès
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Succès'),
            ],
          ),
          content: const Text(
              'Les données d\'exemple ont été créées dans Firebase.\n\n'
              'Vous pouvez maintenant :\n'
              '• Consulter les heures de prière\n'
              '• Voir les événements\n'
              '• Lire les actualités\n'
              '• Explorer la bibliothèque\n'
              '• Gérer le contenu depuis l\'administration'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Aller à l\'accueil'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _status = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'initialisation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _DataItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DataItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
