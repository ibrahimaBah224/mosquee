import 'package:flutter/material.dart';
import '../../../../core/models/muezzin.dart';
import '../../../../core/widgets/cloudinary_image.dart';
import '../../../../core/services/muezzin_service.dart';

class MuezzinsPage extends StatelessWidget {
  const MuezzinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Muezzins'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Muezzin>>(
        stream: MuezzinService().watchAllMuezzins(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Impossible de charger les informations des muezzins',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeSampleData(context),
                    child: const Text('Réessayer avec des données d\'exemple'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final muezzins = snapshot.data ?? [];

          if (muezzins.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.record_voice_over,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun muezzin',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun muezzin n\'est actuellement enregistré',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _initializeSampleData(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer des données d\'exemple'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec description
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Les Voix de l\'Appel',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rencontrez nos muezzins dévoués qui élèvent leurs voix pour appeler les fidèles à la prière. Leur récitation mélodieuse résonne cinq fois par jour.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Liste des muezzins
                for (final muezzin in muezzins)
                  _buildMuezzinCard(context, muezzin),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _initializeSampleData(BuildContext context) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final muezzinService = MuezzinService();
      await muezzinService.initializeSampleMuezzins();

      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.of(context).pop();

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Données d\'exemple créées avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.of(context).pop();

        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMuezzinCard(BuildContext context, Muezzin muezzin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec photo et infos principales
            Row(
              children: [
                CloudinaryAvatar(
                  publicId: muezzin.photoUrl ?? '',
                  radius: 35,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  fallbackIcon: Icons.record_voice_over,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        muezzin.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        muezzin.fullNameArabic,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(muezzin.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          muezzin.statusDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Prières assignées
            if (muezzin.assignedPrayers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Prières assignées',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: muezzin.assignedPrayers.map((prayer) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getPrayerDisplayName(prayer),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Type d'engagement
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: muezzin.isVolunteer
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: muezzin.isVolunteer
                      ? Colors.green.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    muezzin.isVolunteer ? Icons.volunteer_activism : Icons.work,
                    size: 20,
                    color: muezzin.isVolunteer ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    muezzin.isVolunteer ? 'Bénévole' : 'Employé',
                    style: TextStyle(
                      color: muezzin.isVolunteer ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MuezzinStatus status) {
    switch (status) {
      case MuezzinStatus.principal:
        return Colors.purple;
      case MuezzinStatus.assistant:
        return Colors.blue;
      case MuezzinStatus.remplacant:
        return Colors.orange;
    }
  }

  String _getStatusDisplayName(MuezzinStatus status) {
    switch (status) {
      case MuezzinStatus.principal:
        return 'Muezzin Principal';
      case MuezzinStatus.assistant:
        return 'Muezzin Assistant';
      case MuezzinStatus.remplacant:
        return 'Muezzin Remplaçant';
    }
  }

  String _getPrayerDisplayName(PrayerAssignment prayer) {
    switch (prayer) {
      case PrayerAssignment.fajr:
        return 'Fajr';
      case PrayerAssignment.dhuhr:
        return 'Dhuhr';
      case PrayerAssignment.asr:
        return 'Asr';
      case PrayerAssignment.maghrib:
        return 'Maghrib';
      case PrayerAssignment.isha:
        return 'Isha';
      case PrayerAssignment.jumma:
        return 'Jumma';
      case PrayerAssignment.eid:
        return 'Aïd';
      case PrayerAssignment.all:
        return 'Toutes les prières';
    }
  }
}
