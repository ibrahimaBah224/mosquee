import 'package:flutter/material.dart';
import '../../../../core/models/imam.dart';
import '../../../../core/widgets/cloudinary_image.dart';
import '../../../../core/services/imam_service.dart';

class ImamsPage extends StatelessWidget {
  const ImamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Imams'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Imam>>(
        stream: ImamService().watchAllImams(),
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
                    'Impossible de charger les informations des imams',
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

          final imams = snapshot.data ?? [];

          if (imams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun imam',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun imam n\'est actuellement enregistré',
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
                        Icons.mosque,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nos Guides Spirituels',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Découvrez nos imams dévoués qui guident notre communauté dans la foi et la spiritualité. Ils sont là pour vous accompagner dans votre cheminement religieux.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Liste des imams
                for (final imam in imams) _buildImamCard(context, imam),
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

      final imamService = ImamService();
      await imamService.initializeSampleImams();

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

  Widget _buildImamCard(BuildContext context, Imam imam) {
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
                  publicId: imam.photoUrl ?? '',
                  radius: 35,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  fallbackIcon: Icons.person,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        imam.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        imam.fullNameArabic,
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
                          color: _getRankColor(imam.rank),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          imam.rankDisplayName,
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

            if (imam.biography != null && imam.biography!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Biographie',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                imam.biography!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
            ],

            // Spécialités
            if (imam.specialties.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Spécialités',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imam.specialties.map((specialty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getSpecialtyDisplayName(specialty),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Langues parlées
            if (imam.languages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Langues: ${imam.languages.join(', ')}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],

            // Formation
            if (imam.education != null && imam.education!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Formation: ${imam.education!}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Contact (email seulement pour la confidentialité)
            if (imam.email != null && imam.email!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contact: ${imam.email!}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRankColor(ImamRank rank) {
    switch (rank) {
      case ImamRank.principal:
        return Colors.purple;
      case ImamRank.adjoint:
        return Colors.blue;
      case ImamRank.assistant:
        return Colors.orange;
      case ImamRank.visiteur:
        return Colors.green;
    }
  }

  String _getRankDisplayName(ImamRank rank) {
    switch (rank) {
      case ImamRank.principal:
        return 'Imam Principal';
      case ImamRank.adjoint:
        return 'Imam Adjoint';
      case ImamRank.assistant:
        return 'Imam Assistant';
      case ImamRank.visiteur:
        return 'Imam Visiteur';
    }
  }

  String _getSpecialtyDisplayName(ImamSpecialty specialty) {
    switch (specialty) {
      case ImamSpecialty.khutba:
        return 'Prêche du vendredi';
      case ImamSpecialty.tarawih:
        return 'Prières Tarawih';
      case ImamSpecialty.courses:
        return 'Enseignement';
      case ImamSpecialty.marriage:
        return 'Mariages religieux';
      case ImamSpecialty.funeral:
        return 'Services funéraires';
      case ImamSpecialty.general:
        return 'Services généraux';
    }
  }
}
