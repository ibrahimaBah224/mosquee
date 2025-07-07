import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetailPage extends StatelessWidget {
  final String articleId;

  const NewsDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualité'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Découvrez cet article intéressant de la Mosquée Al-Nour : https://mosquee-alnour.fr/news/$articleId',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/news_placeholder.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  const Text(
                    'Célébration de l\'Aïd al-Fitr 2024',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // Métadonnées
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '10 Avril 2024',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 15),
                      const Icon(Icons.person_outline, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Par Imam Ahmed',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Contenu
                  const Text(
                    'La mosquée Al-Nour est heureuse d\'annoncer les célébrations de l\'Aïd al-Fitr qui marqueront la fin du mois sacré de Ramadan.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Programme des festivités :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  _buildProgramItem(
                    '6:30 - Prière de l\'Aïd',
                    'Dans la salle principale de la mosquée',
                  ),
                  _buildProgramItem(
                    '7:30 - Petit-déjeuner communautaire',
                    'Dans la salle de réception',
                  ),
                  _buildProgramItem(
                    '9:00 - Activités pour enfants',
                    'Dans le jardin de la mosquée',
                  ),

                  const SizedBox(height: 20),

                  // Informations importantes
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations importantes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoPoint('Apportez votre tapis de prière'),
                        _buildInfoPoint('Parking disponible à proximité'),
                        _buildInfoPoint('Activités gratuites pour tous'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag('Aïd'),
                      _buildTag('Célébration'),
                      _buildTag('Communauté'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramItem(String time, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
