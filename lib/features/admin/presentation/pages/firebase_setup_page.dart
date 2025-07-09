import 'package:flutter/material.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSetupPage extends StatefulWidget {
  const FirebaseSetupPage({super.key});

  @override
  State<FirebaseSetupPage> createState() => _FirebaseSetupPageState();
}

class _FirebaseSetupPageState extends State<FirebaseSetupPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test des Événements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createSampleEvents,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_circle),
                      label: const Text('Créer des événements d\'exemple'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _deleteSampleEvents,
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer les événements d\'exemple'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testEventsQuery,
                      icon: const Icon(Icons.search),
                      label: const Text('Tester requête événements'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _debugAllEvents,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Debug TOUS les événements'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _fullDiagnostic,
                      icon: const Icon(Icons.analytics),
                      label: const Text('DIAGNOSTIC COMPLET'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _fixExistingEvents,
                      icon: const Icon(Icons.build),
                      label: const Text('CORRIGER ÉVÉNEMENTS EXISTANTS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Créez des événements d\'exemple'),
                    const Text('2. Allez sur la page Événements pour les voir'),
                    const Text('3. Vérifiez les logs dans la console'),
                    const Text('4. Supprimez les exemples quand terminé'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSampleEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.createSampleEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événements d\'exemple créés avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSampleEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.deleteSampleEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événements d\'exemple supprimés !'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEventsQuery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _firestoreService.getUpcomingEvents(limit: 10);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trouvé ${events.length} événement(s)'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      print('📊 Events found: ${events.length}');
      for (var event in events) {
        print('📄 Event: ${event.title} - ${event.status}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de requête : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _debugAllEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _firestoreService.getAllEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trouvé ${events.length} événement(s)'),
            backgroundColor: Colors.purple,
          ),
        );
      }

      print('📊 Events found: ${events.length}');
      for (var event in events) {
        print('📄 Event: ${event.title} - ${event.status}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de requête : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fullDiagnostic() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _testAllQueries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de diagnostic : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAllQueries() async {
    try {
      print('🔍 === DIAGNOSTIC COMPLET (SIMPLIFIÉ) ===');

      // 1. Test du service singleton
      print('🔍 1. Test FirestoreService singleton...');
      final firestoreService = getIt<FirestoreService>();

      // 2. Test getAllEvents
      print('🔍 2. Test getAllEvents...');
      final allEvents = await firestoreService.getAllEvents();
      print('📊 Total événements: ${allEvents.length}');

      for (var event in allEvents) {
        print(
            '📄 Event: ${event.title} - Status: ${event.status} - Date: ${event.startDate}');
      }

      // 3. Test watchPublishedEvents en utilisant first
      print('🔍 3. Test watchPublishedEvents (première émission)...');
      final publishedEvents =
          await firestoreService.watchPublishedEvents().first;
      print('📊 Événements publiés: ${publishedEvents.length}');

      for (var event in publishedEvents) {
        print('📋 Published Event: ${event.title} - Status: ${event.status}');
      }

      // 4. Test watchAllEvents (méthode debug)
      print('🔍 4. Test watchAllEvents (debug)...');
      final allEventsStream = await firestoreService.watchAllEvents().first;
      print('📊 Tous événements via stream: ${allEventsStream.length}');

      // 5. Test getUpcomingEvents
      print('🔍 5. Test getUpcomingEvents...');
      final upcomingEvents =
          await firestoreService.getUpcomingEvents(limit: 10);
      print('📊 Événements à venir: ${upcomingEvents.length}');

      // 6. Analyser les différences
      print('🔍 6. ANALYSE:');
      print('   - Total: ${allEvents.length}');
      print(
          '   - Publiés (via getAllEvents): ${allEvents.where((e) => e.status == EventStatus.published).length}');
      print('   - Publiés (via watchPublished): ${publishedEvents.length}');
      print('   - À venir: ${upcomingEvents.length}');

      print('🔍 === FIN DIAGNOSTIC ===');
    } catch (e) {
      print('❌ Erreur pendant le diagnostic: $e');
      rethrow;
    }
  }

  Future<void> _testEventQueries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Implementation of _testEventQueries method
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de requête : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fixExistingEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.fixExistingEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événements existants corrigés avec succès !'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _DataItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DataItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
