import 'package:flutter/material.dart';

class PrayerSettingsPanel extends StatefulWidget {
  const PrayerSettingsPanel({super.key});

  @override
  State<PrayerSettingsPanel> createState() => _PrayerSettingsPanelState();
}

class _PrayerSettingsPanelState extends State<PrayerSettingsPanel> {
  bool _notificationsEnabled = true;
  bool _adhanSoundEnabled = true;
  bool _vibrationEnabled = false;
  double _volumeLevel = 0.7;
  String _calculationMethod = 'Muslim World League';
  String _madhab = 'Hanafi';

  final List<String> _calculationMethods = [
    'Muslim World League',
    'Egyptian General Authority',
    'University of Islamic Sciences, Karachi',
    'Umm Al-Qura University',
    'Institute of Geophysics University of Tehran',
  ];

  final List<String> _madhabs = ['Hanafi', 'Shafi'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Paramètres des Prières',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            'Activer les notifications',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
            icon: Icons.notifications,
          ),

          if (_notificationsEnabled) ...[
            _buildSwitchTile(
              'Son de l\'Adhan',
              _adhanSoundEnabled,
              (value) => setState(() => _adhanSoundEnabled = value),
              icon: Icons.volume_up,
            ),
            _buildSwitchTile(
              'Vibration',
              _vibrationEnabled,
              (value) => setState(() => _vibrationEnabled = value),
              icon: Icons.vibration,
            ),

            if (_adhanSoundEnabled) ...[
              const SizedBox(height: 16),
              Text(
                'Volume',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Slider(
                value: _volumeLevel,
                onChanged: (value) => setState(() => _volumeLevel = value),
                activeColor: Theme.of(context).primaryColor,
                divisions: 10,
                label: '${(_volumeLevel * 100).round()}%',
              ),
            ],
          ],

          const SizedBox(height: 20),

          // Calculation Method Section
          _buildSectionHeader('Méthode de Calcul'),
          _buildDropdownTile(
            'Méthode',
            _calculationMethod,
            _calculationMethods,
            (value) => setState(() => _calculationMethod = value!),
            icon: Icons.calculate,
          ),

          _buildDropdownTile(
            'École Juridique (Madhab)',
            _madhab,
            _madhabs,
            (value) => setState(() => _madhab = value!),
            icon: Icons.school,
          ),

          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save settings
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sauvegarder'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
              ],
              Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items:
                items.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
          ),
        ],
      ),
    );
  }
}
