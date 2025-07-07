import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/prayer_time.dart';
import '../../../../core/repositories/prayer_repository.dart';
import '../../../../core/di/dependency_injection.dart';

class PrayerManagementPage extends StatefulWidget {
  const PrayerManagementPage({super.key});

  @override
  State<PrayerManagementPage> createState() => _PrayerManagementPageState();
}

class _PrayerManagementPageState extends State<PrayerManagementPage> {
  final PrayerRepository _prayerRepository = getIt<PrayerRepository>();
  final _formKey = GlobalKey<FormState>();

  List<PrayerTime> _prayerTimes = [];
  PrayerConfiguration? _configuration;
  bool _isLoading = true;
  bool _automaticCalculation = true;

  // Controllers pour la configuration
  final _mosqueNameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _timezoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _mosqueNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final config = await _prayerRepository.getConfiguration();
      final prayerTimes =
          await _prayerRepository.getPrayerTimesForDate(DateTime.now());

      setState(() {
        _configuration = config;
        _prayerTimes = prayerTimes;
        _isLoading = false;

        if (config != null) {
          _mosqueNameController.text = config.mosqueName;
          _latitudeController.text = config.latitude.toString();
          _longitudeController.text = config.longitude.toString();
          _timezoneController.text = config.timezone;
          _automaticCalculation = config.automaticCalculation;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final config = PrayerConfiguration(
        id: _configuration?.id ?? 'main',
        mosqueName: _mosqueNameController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        timezone: _timezoneController.text,
        calculationMethod: 'ISNA', // À personnaliser
        adjustments: _configuration?.adjustments ?? {},
        automaticCalculation: _automaticCalculation,
        updatedAt: DateTime.now(),
      );

      await _prayerRepository.updateConfiguration(config);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration sauvegardée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _adjustPrayerTime(PrayerTime prayer, int adjustment) async {
    try {
      await _prayerRepository.adjustPrayerTime(prayer.id, adjustment);
      await _loadData(); // Recharger les données

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horaire de ${prayer.name} ajusté')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Prières'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfiguration,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Configuration de la mosquée
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuration de la Mosquée',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _mosqueNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom de la mosquée',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Requis' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _latitudeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Latitude',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value?.isEmpty == true)
                                        return 'Requis';
                                      if (double.tryParse(value!) == null)
                                        return 'Nombre invalide';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _longitudeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Longitude',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value?.isEmpty == true)
                                        return 'Requis';
                                      if (double.tryParse(value!) == null)
                                        return 'Nombre invalide';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _timezoneController,
                              decoration: const InputDecoration(
                                labelText: 'Fuseau horaire (ex: Europe/Paris)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Requis' : null,
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Calcul automatique'),
                              subtitle: const Text(
                                  'Calculer automatiquement les heures selon la position'),
                              value: _automaticCalculation,
                              onChanged: (value) {
                                setState(() => _automaticCalculation = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ajustement des heures de prière
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Heures de Prière du Jour',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            if (_prayerTimes.isEmpty)
                              const Center(
                                child:
                                    Text('Aucune heure de prière configurée'),
                              )
                            else
                              ..._prayerTimes.map(
                                  (prayer) => _buildPrayerTimeCard(prayer)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Recalculer les horaires'),
                            onPressed: () {
                              // Logique pour recalculer les horaires
                              _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPrayerTimeCard(PrayerTime prayer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    prayer.nameArabic,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                prayer.adjustedTime,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () =>
                      _adjustPrayerTime(prayer, prayer.adjustmentMinutes - 1),
                  tooltip: 'Reculer d\'1 minute',
                ),
                Text(
                    '${prayer.adjustmentMinutes >= 0 ? '+' : ''}${prayer.adjustmentMinutes}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () =>
                      _adjustPrayerTime(prayer, prayer.adjustmentMinutes + 1),
                  tooltip: 'Avancer d\'1 minute',
                ),
              ],
            ),
            Switch(
              value: prayer.isEnabled,
              onChanged: (value) {
                // Logique pour activer/désactiver une prière
              },
            ),
          ],
        ),
      ),
    );
  }
}
