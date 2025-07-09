import 'package:flutter/material.dart';
import '../../../../core/widgets/cloudinary_image.dart';
import '../../../../core/services/cloudinary_service.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String category;
  final String? imageUrl;
  final bool isRegistered;
  final VoidCallback onTap;
  final VoidCallback onRegister;

  const EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    this.imageUrl,
    this.isRegistered = false,
    required this.onTap,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image ou placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CloudinaryImage(
                      publicId: imageUrl!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      quality: CloudinaryImageQuality.medium,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      placeholder: _buildPlaceholder(context),
                      errorWidget: _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie et statut
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Spacer(),
                      if (isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Inscrit',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Titre
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Date et lieu
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bouton d'inscription
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isRegistered ? null : onRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        isRegistered ? 'Déjà inscrit' : 'S\'inscrire',
                      ),
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

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(Icons.event, size: 48, color: Theme.of(context).primaryColor),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }
}
