import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../bloc/mosque_info_bloc.dart';

class PrayerTimesCard extends StatelessWidget {
  const PrayerTimesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2E7D32),
                const Color(0xFF1565C0),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Motif mosquée en arrière-plan
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: MosquePatternPainter(),
                  ),
                ),
              ),

              // Contenu principal
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Horaires des Prières',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              BlocBuilder<MosqueInfoBloc, MosqueInfoState>(
                                builder: (context, state) {
                                  String mosqueLocation = 'Chargement...';

                                  if (state is MosqueInfoLoaded) {
                                    mosqueLocation =
                                        '${state.mosqueInfo.name} • ${state.mosqueInfo.city}';
                                  } else if (state is MosqueInfoError) {
                                    mosqueLocation = 'Erreur de chargement';
                                  }

                                  return Text(
                                    mosqueLocation,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Bouton refresh
                        IconButton(
                          onPressed: () {
                            context
                                .read<PrayerBloc>()
                                .add(RefreshPrayerTimes());
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          tooltip: 'Actualiser',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Liste des prières
                    BlocBuilder<PrayerBloc, PrayerState>(
                      builder: (context, state) {
                        if (state is PrayerLoading) {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          );
                        }

                        if (state is PrayerError) {
                          return Center(
                            child: Column(
                              children: [
                                Icon(Icons.error,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Erreur de chargement',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.9)),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is PrayerLoaded) {
                          // Si pas de données Firebase, afficher des données par défaut
                          if (state.prayerTimes.isEmpty) {
                            return _buildDefaultPrayerTimes();
                          }

                          return Column(
                            children: state.prayerTimes.map((prayer) {
                              final isNext = state.nextPrayer?.id == prayer.id;
                              return _buildPrayerTimeRow(
                                prayer.name,
                                prayer.nameArabic,
                                prayer.adjustedTime,
                                isNext: isNext,
                              );
                            }).toList(),
                          );
                        }

                        return _buildDefaultPrayerTimes();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Footer avec localisation dynamique
                    BlocBuilder<MosqueInfoBloc, MosqueInfoState>(
                      builder: (context, state) {
                        String coordinates = 'Coordonnées : Chargement...';

                        if (state is MosqueInfoLoaded) {
                          coordinates =
                              'Coordonnées : ${state.mosqueInfo.coordinates}';
                        } else if (state is MosqueInfoError) {
                          coordinates = 'Coordonnées : Non disponibles';
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                coordinates,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildDefaultPrayerTimes() {
    return Column(
      children: [
        _buildPrayerTimeRow('Fajr', 'الفجر', '05:30'),
        _buildPrayerTimeRow('Dhuhr', 'الظهر', '12:45', isNext: true),
        _buildPrayerTimeRow('Asr', 'العصر', '15:30'),
        _buildPrayerTimeRow('Maghrib', 'المغرب', '18:15'),
        _buildPrayerTimeRow('Isha', 'العشاء', '20:00'),
      ],
    );
  }

  Widget _buildPrayerTimeRow(String name, String arabicName, String time,
      {bool isNext = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            isNext ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          // Indicateur prochaine prière
          if (isNext) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Nom de la prière
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isNext ? 16 : 15,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                Text(
                  arabicName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Heure
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: isNext ? 18 : 16,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          // Indicateur prochaine prière (texte)
          if (isNext) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Prochaine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom painter pour le motif mosquée
class MosquePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Dessiner des motifs géométriques islamiques simples
    final path = Path();

    // Motifs en losange
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 2; j++) {
        final x = (i * 60.0) + 30;
        final y = (j * 80.0) + 40;

        path.reset();
        path.moveTo(x, y - 15);
        path.lineTo(x + 15, y);
        path.lineTo(x, y + 15);
        path.lineTo(x - 15, y);
        path.close();

        canvas.drawPath(path, paint);
      }
    }

    // Lignes décoratives
    for (int i = 0; i < 4; i++) {
      final y = (i * 40.0) + 20;
      canvas.drawLine(
        Offset(size.width - 60, y),
        Offset(size.width - 20, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
