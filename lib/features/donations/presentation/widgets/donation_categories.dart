import 'package:flutter/material.dart';

class DonationCategories extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const DonationCategories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Zakat',
      'icon': Icons.mosque,
      'color': Colors.green,
      'description': 'Obligation religieuse',
    },
    {
      'name': 'Sadaqah',
      'icon': Icons.favorite,
      'color': Colors.blue,
      'description': 'Charité volontaire',
    },
    {
      'name': 'Mosquée',
      'icon': Icons.architecture,
      'color': Colors.orange,
      'description': 'Entretien et travaux',
    },
    {
      'name': 'Éducation',
      'icon': Icons.school,
      'color': Colors.purple,
      'description': 'École coranique',
    },
    {
      'name': 'Orphelins',
      'icon': Icons.child_care,
      'color': Colors.pink,
      'description': 'Aide aux orphelins',
    },
    {
      'name': 'Urgence',
      'icon': Icons.emergency,
      'color': Colors.red,
      'description': 'Aide d\'urgence',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir une catégorie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['name'];

            return GestureDetector(
              onTap: () => onCategorySelected(category['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? category['color'].withOpacity(0.1)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? category['color'] : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: category['color'].withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? category['color']
                                : category['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category['icon'],
                        color: isSelected ? Colors.white : category['color'],
                        size: 24,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? category['color'] : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      category['description'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
}
