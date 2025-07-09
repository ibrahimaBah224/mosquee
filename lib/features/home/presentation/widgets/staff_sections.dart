import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/imam.dart';
import '../../../../core/models/muezzin.dart';
import '../../../../core/services/imam_service.dart';
import '../../../../core/services/muezzin_service.dart';
import '../../../../core/widgets/cloudinary_image.dart';

/// Section pour afficher les imams sur la page d'accueil
class ImamsSection extends StatelessWidget {
  const ImamsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Imam>>(
      future: ImamService().getAllImams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SectionSkeleton(
            title: 'Nos Imams',
            icon: Icons.mosque,
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final imams = snapshot.data!;
        if (imams.isEmpty) return const SizedBox.shrink();

        // Afficher maximum 3 imams sur l'accueil
        final displayedImams = imams.take(3).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de section
                  _buildSectionHeader(
                    context: context,
                    title: 'Nos Imams',
                    subtitle:
                        'Nos guides spirituels au service de la communauté',
                    icon: Icons.mosque,
                    route: '/imams',
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Liste des imams
                  _buildStaffList(
                    items: displayedImams,
                    itemBuilder: (imam) => _ImamCard(
                      imam: imam,
                      isCompact: isSmallScreen,
                    ),
                    isSmallScreen: isSmallScreen,
                    isMediumScreen: isMediumScreen,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Section pour afficher les muezzins sur la page d'accueil
class MuezzinsSection extends StatelessWidget {
  const MuezzinsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Muezzin>>(
      future: MuezzinService().getAllMuezzins(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SectionSkeleton(
            title: 'Nos Muezzins',
            icon: Icons.record_voice_over,
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final muezzins = snapshot.data!;
        if (muezzins.isEmpty) return const SizedBox.shrink();

        // Afficher maximum 3 muezzins sur l'accueil
        final displayedMuezzins = muezzins.take(3).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth < 900;

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de section
                  _buildSectionHeader(
                    context: context,
                    title: 'Nos Muezzins',
                    subtitle: 'Les voix qui appellent à la prière chaque jour',
                    icon: Icons.record_voice_over,
                    route: '/muezzins',
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Liste des muezzins
                  _buildStaffList(
                    items: displayedMuezzins,
                    itemBuilder: (muezzin) => _MuezzinCard(
                      muezzin: muezzin,
                      isCompact: isSmallScreen,
                    ),
                    isSmallScreen: isSmallScreen,
                    isMediumScreen: isMediumScreen,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget réutilisable pour l'en-tête des sections
Widget _buildSectionHeader({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required String route,
  required bool isSmallScreen,
}) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 18 : null,
                      ),
                ),
                if (!isSmallScreen)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 12 : null,
                        ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => context.go(route),
            icon: Icon(
              Icons.arrow_forward,
              size: isSmallScreen ? 14 : 16,
            ),
            label: Text(
              'Voir plus',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 16,
                vertical: isSmallScreen ? 4 : 8,
              ),
            ),
          ),
        ],
      ),
      if (isSmallScreen)
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 34),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
            ),
          ),
        ),
    ],
  );
}

/// Widget réutilisable pour les listes de staff
Widget _buildStaffList<T>({
  required List<T> items,
  required Widget Function(T) itemBuilder,
  required bool isSmallScreen,
  required bool isMediumScreen,
}) {
  if (isSmallScreen) {
    // Pour les petits écrans : layout vertical avec cartes compactes
    return Column(
      children: items
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: itemBuilder(item),
              ))
          .toList(),
    );
  } else {
    // Pour les écrans moyens/grands : layout horizontal scrollable
    final cardWidth = isMediumScreen ? 140.0 : 160.0;
    final cardHeight = isMediumScreen ? 180.0 : 200.0;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(
              right: index < items.length - 1 ? 12 : 0,
            ),
            child: itemBuilder(item),
          );
        },
      ),
    );
  }
}

/// Widget card pour afficher un imam
class _ImamCard extends StatelessWidget {
  final Imam imam;
  final bool isCompact;

  const _ImamCard({
    required this.imam,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    } else {
      return _buildStandardCard(context);
    }
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Photo de profil
            CloudinaryAvatar(
              publicId: imam.photoUrl ?? '',
              radius: 24,
              backgroundColor: _getRankColor(imam.rank).withOpacity(0.1),
              fallbackIcon: Icons.person,
            ),

            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom
                  Text(
                    imam.fullName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Nom arabe
                  if (imam.fullNameArabic.isNotEmpty)
                    Text(
                      imam.fullNameArabic,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 6),

                  // Badge du rang
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRankColor(imam.rank),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      imam.rankDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Spécialités (icônes seulement)
            if (imam.specialties.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: imam.specialties.take(2).map((specialty) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getSpecialtyIcon(specialty),
                      size: 12,
                      color: Colors.blue[700],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo de profil
            CloudinaryAvatar(
              publicId: imam.photoUrl ?? '',
              radius: 28,
              backgroundColor: _getRankColor(imam.rank).withOpacity(0.1),
              fallbackIcon: Icons.person,
            ),

            const SizedBox(height: 8),

            // Nom
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    imam.fullName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (imam.fullNameArabic.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      imam.fullNameArabic,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 10,
                          ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Badge du rang
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _getRankColor(imam.rank),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                imam.rankDisplayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 6),

            // Spécialités (max 2)
            Expanded(
              flex: 1,
              child: imam.specialties.isNotEmpty
                  ? Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      alignment: WrapAlignment.center,
                      children:
                          imam.specialtyDisplayNames.take(2).map((specialty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            specialty,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 8,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
            ),
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
        return Colors.green;
      case ImamRank.visiteur:
        return Colors.orange;
    }
  }

  IconData _getSpecialtyIcon(ImamSpecialty specialty) {
    switch (specialty) {
      case ImamSpecialty.khutba:
        return Icons.mic;
      case ImamSpecialty.tarawih:
        return Icons.nightlight_round;
      case ImamSpecialty.courses:
        return Icons.school;
      case ImamSpecialty.general:
        return Icons.psychology;
      case ImamSpecialty.marriage:
        return Icons.favorite;
      case ImamSpecialty.funeral:
        return Icons.local_florist;
    }
  }
}

/// Widget card pour afficher un muezzin
class _MuezzinCard extends StatelessWidget {
  final Muezzin muezzin;
  final bool isCompact;

  const _MuezzinCard({
    required this.muezzin,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    } else {
      return _buildStandardCard(context);
    }
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Photo de profil
            CloudinaryAvatar(
              publicId: muezzin.photoUrl ?? '',
              radius: 24,
              backgroundColor: _getStatusColor(muezzin.status).withOpacity(0.1),
              fallbackIcon: Icons.record_voice_over,
            ),

            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom
                  Text(
                    muezzin.fullName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Nom arabe
                  if (muezzin.fullNameArabic.isNotEmpty)
                    Text(
                      muezzin.fullNameArabic,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 6),

                  // Badge du statut
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(muezzin.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      muezzin.statusDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Prières assignées (icônes seulement)
            if (muezzin.assignedPrayers.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: muezzin.assignedPrayers.take(2).map((prayer) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getPrayerIcon(prayer),
                      size: 12,
                      color: Colors.purple[700],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo de profil
            CloudinaryAvatar(
              publicId: muezzin.photoUrl ?? '',
              radius: 28,
              backgroundColor: _getStatusColor(muezzin.status).withOpacity(0.1),
              fallbackIcon: Icons.record_voice_over,
            ),

            const SizedBox(height: 8),

            // Nom
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    muezzin.fullName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (muezzin.fullNameArabic.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      muezzin.fullNameArabic,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 10,
                          ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Badge du statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _getStatusColor(muezzin.status),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                muezzin.statusDisplayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 6),

            // Prières assignées (max 2)
            Expanded(
              flex: 1,
              child: muezzin.assignedPrayers.isNotEmpty
                  ? Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      alignment: WrapAlignment.center,
                      children: muezzin.assignedPrayersDisplayNames
                          .take(2)
                          .map((prayer) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            prayer,
                            style: TextStyle(
                              color: Colors.purple[700],
                              fontSize: 8,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
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

  IconData _getPrayerIcon(PrayerAssignment prayer) {
    switch (prayer) {
      case PrayerAssignment.fajr:
        return Icons.wb_twilight;
      case PrayerAssignment.dhuhr:
        return Icons.wb_sunny;
      case PrayerAssignment.asr:
        return Icons.wb_sunny_outlined;
      case PrayerAssignment.maghrib:
        return Icons.wb_incandescent;
      case PrayerAssignment.isha:
        return Icons.nightlight;
      case PrayerAssignment.jumma:
        return Icons.mosque;
      case PrayerAssignment.eid:
        return Icons.celebration;
      case PrayerAssignment.all:
        return Icons.all_inclusive;
    }
  }
}

/// Widget skeleton pour le chargement responsive
class _SectionSkeleton extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionSkeleton({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header skeleton
              Row(
                children: [
                  Container(
                    width: isSmallScreen ? 32 : 40,
                    height: isSmallScreen ? 32 : 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: isSmallScreen ? 16 : 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (!isSmallScreen) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 200,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Content skeleton
              if (isSmallScreen)
                // Vertical layout pour petits écrans
                Column(
                  children: List.generate(
                      3,
                      (index) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: _buildSkeletonCard(isCompact: true),
                          )),
                )
              else
                // Horizontal layout pour grands écrans
                SizedBox(
                  height: constraints.maxWidth < 900 ? 180 : 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: constraints.maxWidth < 900 ? 140 : 160,
                        margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                        child: _buildSkeletonCard(isCompact: false),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard({required bool isCompact}) {
    if (isCompact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
