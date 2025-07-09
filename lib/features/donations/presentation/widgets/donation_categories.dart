import 'package:flutter/material.dart';
import '../../../../core/models/donation.dart';

class DonationCategories extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const DonationCategories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  // Catégories par défaut - peuvent être étendues via l'interface admin
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'id': 'masjid',
      'name': 'Mosquée',
      'description': 'Entretien et rénovation de la mosquée',
      'icon': Icons.mosque,
      'color': Colors.green,
    },
    {
      'id': 'charity',
      'name': 'Charité',
      'description': 'Aide aux personnes dans le besoin',
      'icon': Icons.volunteer_activism,
      'color': Colors.blue,
    },
    {
      'id': 'education',
      'name': 'Éducation',
      'description': 'Programmes éducatifs et formation',
      'icon': Icons.school,
      'color': Colors.orange,
    },
    {
      'id': 'events',
      'name': 'Événements',
      'description': 'Organisation d\'événements communautaires',
      'icon': Icons.event,
      'color': Colors.purple,
    },
    {
      'id': 'emergency',
      'name': 'Urgence',
      'description': 'Fonds d\'urgence pour les crises',
      'icon': Icons.emergency,
      'color': Colors.red,
    },
    {
      'id': 'general',
      'name': 'Général',
      'description': 'Fonds général de la mosquée',
      'icon': Icons.account_balance,
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez une catégorie',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: defaultCategories.length,
          itemBuilder: (context, index) {
            final category = defaultCategories[index];
            final isSelected = selectedCategory == category['id'];

            return GestureDetector(
              onTap: () => onCategorySelected(category['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category['color'].withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? category['color'] : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: 32,
                      color: isSelected ? category['color'] : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? category['color'] : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['description'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Méthode utilitaire pour obtenir le nom d'affichage d'une catégorie
  static String getCategoryDisplayName(String categoryId) {
    final category = defaultCategories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': categoryId},
    );
    return category['name'];
  }

  /// Méthode utilitaire pour obtenir l'icône d'une catégorie
  static IconData getCategoryIcon(String categoryId) {
    final category = defaultCategories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'icon': Icons.account_balance},
    );
    return category['icon'];
  }

  /// Méthode utilitaire pour obtenir la couleur d'une catégorie
  static Color getCategoryColor(String categoryId) {
    final category = defaultCategories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'color': Colors.grey},
    );
    return category['color'];
  }
}
