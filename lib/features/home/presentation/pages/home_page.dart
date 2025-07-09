import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/prayer_times_card.dart';
import '../widgets/upcoming_events_section.dart';
import '../widgets/latest_news_section.dart';
import '../widgets/donation_banner.dart';
import '../widgets/staff_sections.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../bloc/mosque_info_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec hero section
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.8),
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Motifs géométriques flottants
                    ...List.generate(6, (index) {
                      return Positioned(
                        top: 50 + (index * 40.0),
                        left: (index % 2 == 0) ? -20 : null,
                        right: (index % 2 == 1) ? -20 : null,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _controller.value * 2,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),

                    // Contenu principal
                    Positioned.fill(
                      child: SafeArea(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),

                                // Salutation
                                Text(
                                  'السلام عليكم',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                      ),
                                ),

                                const SizedBox(height: 8),

                                BlocBuilder<MosqueInfoBloc, MosqueInfoState>(
                                  builder: (context, state) {
                                    String welcomeMessage = 'Bienvenue';

                                    if (state is MosqueInfoLoaded) {
                                      welcomeMessage =
                                          'Bienvenue à la ${state.mosqueInfo.name}';
                                    } else if (state is MosqueInfoError) {
                                      welcomeMessage = 'Bienvenue à la mosquée';
                                    }

                                    return Text(
                                      welcomeMessage,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Prochaine prière avec glassmorphism
                                BlocBuilder<PrayerBloc, PrayerState>(
                                  builder: (context, state) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Prochaine prière',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                state is PrayerLoaded &&
                                                        state.nextPrayer != null
                                                    ? '${state.nextPrayer!.name} • ${state.nextPrayer!.adjustedTime}'
                                                    : 'Dhuhr • 12:45',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu scrollable
          SliverList(
            delegate: SliverChildListDelegate([
              // Actions rapides
              const QuickActionsGrid(),

              const SizedBox(height: 24),

              // Horaires de prière
              const PrayerTimesCard(),

              const SizedBox(height: 24),

              // Section Imams
              const ImamsSection(),

              const SizedBox(height: 24),

              // Section Muezzins
              const MuezzinsSection(),

              const SizedBox(height: 24),

              // Événements à venir
              const UpcomingEventsSection(),

              const SizedBox(height: 24),

              // Dernières actualités
              const LatestNewsSection(),

              const SizedBox(height: 24),

              // Bannière de don
              const DonationBanner(),

              const SizedBox(height: 100), // Espace pour la bottom nav
            ]),
          ),
        ],
      ),

      // Bouton d'accès admin (toujours visible)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/login'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text('Admin'),
        tooltip: 'Accès administration',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
