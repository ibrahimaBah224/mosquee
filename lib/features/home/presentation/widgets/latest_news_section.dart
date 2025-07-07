import 'package:flutter/material.dart';

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Actualités', style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () {
                // Navigation vers toutes les actualités
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildNewsCard(context, index),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNewsCard(BuildContext context, int index) {
    final news = [
      {
        'title': 'Nouvelle collecte pour les familles nécessiteuses',
        'summary':
            'La mosquée lance une nouvelle campagne de solidarité pour aider les familles en difficulté.',
        'date': 'Il y a 2 heures',
        'category': 'Solidarité',
      },
      {
        'title': 'Horaires Ramadan 2024',
        'summary':
            'Découvrez les nouveaux horaires de la mosquée pendant le mois béni de Ramadan.',
        'date': 'Hier',
        'category': 'Informations',
      },
      {
        'title': 'Nouveau cours d\'apprentissage du Coran',
        'summary':
            'Inscription ouverte pour les cours de mémorisation du Coran pour tous les âges.',
        'date': 'Il y a 3 jours',
        'category': 'Éducation',
      },
    ];

    final article = news[index];

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          // Navigation vers l'article
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    article['category']!,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(article['category']!),
                  color: _getCategoryColor(article['category']!),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              article['category']!,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            article['category']!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(article['category']!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          article['date']!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article['title']!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article['summary']!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Solidarité':
        return Colors.green;
      case 'Informations':
        return Colors.blue;
      case 'Éducation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Solidarité':
        return Icons.volunteer_activism;
      case 'Informations':
        return Icons.info;
      case 'Éducation':
        return Icons.school;
      default:
        return Icons.article;
    }
  }
}
