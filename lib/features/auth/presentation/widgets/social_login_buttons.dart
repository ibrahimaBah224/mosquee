import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[400])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ou continuer avec',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[400])),
          ],
        ),

        const SizedBox(height: 24),

        // Google Login (temporairement désactivé)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Temporairement désactivé - nécessite configuration web
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Google Sign-In nécessite une configuration web.\n'
                    'Veuillez configurer le Client ID dans Firebase Console.',
                    style: TextStyle(fontSize: 14),
                  ),
                  duration: Duration(seconds: 4),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.g_mobiledata, size: 24),
            label: const Text('Continuer avec Google (Configuration requise)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.orange[300]!),
              foregroundColor: Colors.orange[700],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Apple Login (pour iOS principalement)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement Apple login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connexion Apple bientôt disponible'),
                ),
              );
            },
            icon: const Icon(Icons.apple, size: 24),
            label: const Text('Continuer avec Apple'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Guest Mode
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
          child: Text(
            'Continuer en mode invité',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
