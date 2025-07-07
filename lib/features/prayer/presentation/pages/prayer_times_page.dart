import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/prayer_bloc.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/qibla_compass.dart';
import '../widgets/islamic_calendar.dart';
import '../widgets/prayer_settings_panel.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/prayer_time_service.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  final PrayerTimeService _prayerService = PrayerTimeService();
  late DateTime _selectedDate;
  late Map<String, DateTime> _prayerTimes;
  bool _isLoading = true;
  String _nextPrayer = '';
  DateTime? _nextPrayerTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _isLoading = true);
    try {
      _prayerTimes = await _prayerService.getPrayerTimes(_selectedDate);
      _nextPrayer = _prayerService.findNextPrayer(_prayerTimes);
      _nextPrayerTime = _prayerTimes[_nextPrayer];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horaires des Prières'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar personnalisé
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Horaires de Prière'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A237E).withOpacity(0.9),
                      const Color(0xFF3F51B5).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Affichage de la date hijri
                    Positioned(
                      bottom: 60,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE d MMMM y').format(_selectedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            '15 Ramadan 1445', // À remplacer par la vraie date hijri
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Sélecteur de date
                      _buildDateSelector(),

                      // Carte de la prochaine prière
                      _buildNextPrayerCard(),

                      // Liste des prières
                      _buildPrayersList(),

                      // Options supplémentaires
                      _buildAdditionalOptions(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                _loadPrayerTimes();
              });
            },
          ),
          TextButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2025),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                  _loadPrayerTimes();
                });
              }
            },
            child: Text(
              DateFormat('d MMMM').format(_selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
                _loadPrayerTimes();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    if (_nextPrayer.isEmpty || _nextPrayerTime == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'Prochaine prière',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _nextPrayer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _prayerService.formatPrayerTime(_nextPrayerTime!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _prayerService.getTimeUntilNextPrayer(_nextPrayerTime!),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayersList() {
    if (_prayerTimes.isEmpty) {
      return const SizedBox.shrink();
    }

    final prayers = [
      {'name': 'Fajr', 'icon': Icons.nightlight_round},
      {'name': 'Sunrise', 'icon': Icons.wb_sunny},
      {'name': 'Dhuhr', 'icon': Icons.wb_sunny},
      {'name': 'Asr', 'icon': Icons.wb_cloudy},
      {'name': 'Maghrib', 'icon': Icons.nightlight},
      {'name': 'Isha', 'icon': Icons.bedtime},
    ];

    return Column(
      children: prayers.map((prayer) {
        final name = prayer['name'] as String;
        final time = _prayerTimes[name];
        if (time == null) return const SizedBox.shrink();

        return _buildPrayerItem({
          'name': name,
          'time': _prayerService.formatPrayerTime(time),
          'icon': prayer['icon'] as IconData,
        });
      }).toList(),
    );
  }

  Widget _buildPrayerItem(Map<String, dynamic> prayer) {
    final bool isActive = prayer['name'] == _nextPrayer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Theme.of(context).primaryColor : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            prayer['icon'] as IconData,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
        title: Text(
          prayer['name'] as String,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          prayer['time'] as String,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Theme.of(context).primaryColor : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOptionButton(
            icon: Icons.explore,
            title: 'Direction de la Qibla',
            onTap: () => Navigator.pushNamed(context, '/qibla'),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.calendar_today,
            title: 'Calendrier islamique',
            onTap: () => Navigator.pushNamed(context, '/calendar'),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.notifications,
            title: 'Paramètres des notifications',
            onTap: () =>
                Navigator.pushNamed(context, '/settings/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PrayerSettingsPanel(),
    );
  }
}
