import 'package:flutter/material.dart';

class DonationCategorySelector extends StatefulWidget {
  final Function(String) onCategoryChanged;

  const DonationCategorySelector({super.key, required this.onCategoryChanged});

  @override
  State<DonationCategorySelector> createState() =>
      _DonationCategorySelectorState();
}

class _DonationCategorySelectorState extends State<DonationCategorySelector> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'zakat',
      'title': 'Zakat',
      'description': 'Pilier de l\'Islam - Purification des biens',
      'icon': Icons.stars,
      'color': Color(0xFF2E7D32),
    },
    {
      'id': 'sadaqah',
      'title': 'Sadaqah',
      'description':
          'Charité volontaire pour la recherche de la satisfaction d\'Allah',
      'icon': Icons.favorite,
      'color': Color(0xFFFFB300),
    },
    {
      'id': 'mosque',
      'title': 'Mosquée',
      'description': 'Entretien et développement de la mosquée',
      'icon': Icons.mosque,
      'color': Color(0xFF1565C0),
    },
    {
      'id': 'education',
      'title': 'Éducation',
      'description': 'Programmes éducatifs et cours islamiques',
      'icon': Icons.school,
      'color': Color(0xFF7B1FA2),
    },
    {
      'id': 'humanitarian',
      'title': 'Humanitaire',
      'description': 'Aide aux nécessiteux et actions sociales',
      'icon': Icons.volunteer_activism,
      'color': Color(0xFFD32F2F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir une catégorie',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Column(
          children:
              _categories.map((category) {
                final isSelected = _selectedCategory == category['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['id'];
                      });
                      widget.onCategoryChanged(category['id']);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? category['color'].withOpacity(0.1)
                                : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? category['color']
                                  : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category['icon'],
                              color: category['color'],
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category['title'],
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected ? category['color'] : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category['description'],
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),

                          if (isSelected)
                            Icon(Icons.check_circle, color: category['color']),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Toutes les donations sont utilisées conformément aux principes islamiques et font l\'objet d\'une gestion transparente.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
