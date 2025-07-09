import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/mosque_info_bloc.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MosqueInfoBloc, MosqueInfoState>(
      builder: (context, state) {
        // Valeurs par défaut en cas de chargement ou d'erreur
        String mosqueName = 'MOMED';
        String location = 'Chargement...';

        if (state is MosqueInfoLoaded) {
          mosqueName = state.mosqueInfo.name;
          location = '${state.mosqueInfo.city}, ${state.mosqueInfo.country}';
        } else if (state is MosqueInfoError) {
          location = 'Erreur de chargement';
        }

        return AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              // Logo de la mosquée
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback vers l'icône mosquée si le logo ne charge pas
                      return const Icon(
                        Icons.mosque,
                        size: 24,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Texte du titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosqueName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      location,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications - À venir')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                context.go('/profile');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
