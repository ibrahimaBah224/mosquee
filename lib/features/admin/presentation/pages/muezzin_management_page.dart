import 'package:flutter/material.dart';
import '../../../../core/models/muezzin.dart';
import '../../../../core/services/muezzin_service.dart';

class MuezzinManagementPage extends StatefulWidget {
  const MuezzinManagementPage({super.key});

  @override
  State<MuezzinManagementPage> createState() => _MuezzinManagementPageState();
}

class _MuezzinManagementPageState extends State<MuezzinManagementPage> {
  final MuezzinService _muezzinService = MuezzinService();
  final TextEditingController _searchController = TextEditingController();

  List<Muezzin> _muezzins = [];
  List<Muezzin> _filteredMuezzins = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMuezzins();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterMuezzins();
    });
  }

  void _filterMuezzins() {
    if (_searchQuery.isEmpty) {
      _filteredMuezzins = List.from(_muezzins);
    } else {
      _filteredMuezzins = _muezzins.where((muezzin) {
        final query = _searchQuery.toLowerCase();
        return muezzin.firstName.toLowerCase().contains(query) ||
            muezzin.lastName.toLowerCase().contains(query) ||
            muezzin.fullNameArabic.toLowerCase().contains(query) ||
            muezzin.statusDisplayName.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _loadMuezzins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final muezzins = await _muezzinService.getAllMuezzins();
      setState(() {
        _muezzins = muezzins;
        _filterMuezzins();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Muezzins'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMuezzins,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMuezzinDialog(),
            tooltip: 'Ajouter un Muezzin',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header avec statistiques
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo, Colors.indigo.shade700],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Muezzins',
                        '${_muezzins.length}',
                        Icons.record_voice_over,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Principal',
                        _muezzins
                            .where((m) => m.status == MuezzinStatus.principal)
                            .length
                            .toString(),
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Actifs',
                        _muezzins.where((m) => m.isActive).length.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un Muezzin...',
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Liste des Muezzins
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMuezzins.isEmpty
                    ? _buildEmptyState()
                    : _buildMuezzinsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun Muezzin trouvé pour "$_searchQuery"'
                : 'Aucun Muezzin enregistré',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Essayez avec d\'autres mots-clés'
                : 'Ajoutez votre premier Muezzin',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddMuezzinDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un Muezzin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuezzinsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMuezzins.length,
      itemBuilder: (context, index) {
        final muezzin = _filteredMuezzins[index];
        return _buildMuezzinCard(muezzin);
      },
    );
  }

  Widget _buildMuezzinCard(Muezzin muezzin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getStatusColor(muezzin.status),
                  backgroundImage: muezzin.photoUrl?.isNotEmpty == true
                      ? NetworkImage(muezzin.photoUrl!)
                      : null,
                  child: muezzin.photoUrl?.isEmpty != false
                      ? const Icon(Icons.record_voice_over,
                          color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),

                // Informations principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        muezzin.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        muezzin.fullNameArabic,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(muezzin.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _getStatusColor(muezzin.status)
                                      .withOpacity(0.3)),
                            ),
                            child: Text(
                              muezzin.statusDisplayName,
                              style: TextStyle(
                                color: _getStatusColor(muezzin.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: muezzin.isVolunteer
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              muezzin.employmentType,
                              style: TextStyle(
                                color: muezzin.isVolunteer
                                    ? Colors.blue
                                    : Colors.green,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditMuezzinDialog(muezzin);
                        break;
                      case 'delete':
                        _deleteMuezzin(muezzin);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Prières assignées
            if (muezzin.assignedPrayers.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    muezzin.assignedPrayersDisplayNames.take(4).map((prayer) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Text(
                      prayer,
                      style: TextStyle(
                        color: Colors.purple[700],
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Informations additionnelles
            Row(
              children: [
                if (muezzin.performanceRating != null) ...[
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${muezzin.performanceRating!.toStringAsFixed(1)}/5',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                ],
                if (muezzin.hasContact) ...[
                  Icon(Icons.contact_phone, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Contact',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
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

  Future<void> _deleteMuezzin(Muezzin muezzin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer le Muezzin ${muezzin.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _muezzinService.deleteMuezzin(muezzin.id);
        _loadMuezzins();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Muezzin supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddMuezzinDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddEditMuezzinDialog(
        onSaved: () {
          _loadMuezzins();
        },
      ),
    );
  }

  void _showEditMuezzinDialog(Muezzin muezzin) {
    showDialog(
      context: context,
      builder: (context) => _AddEditMuezzinDialog(
        muezzin: muezzin,
        onSaved: () {
          _loadMuezzins();
        },
      ),
    );
  }
}

// Dialog pour ajouter/modifier un Muezzin
class _AddEditMuezzinDialog extends StatefulWidget {
  final Muezzin? muezzin;
  final VoidCallback onSaved;

  const _AddEditMuezzinDialog({
    this.muezzin,
    required this.onSaved,
  });

  @override
  State<_AddEditMuezzinDialog> createState() => _AddEditMuezzinDialogState();
}

class _AddEditMuezzinDialogState extends State<_AddEditMuezzinDialog> {
  final _formKey = GlobalKey<FormState>();
  final MuezzinService _muezzinService = MuezzinService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _arabicNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _voiceQualityController;
  late TextEditingController _trainingController;

  MuezzinStatus _selectedStatus = MuezzinStatus.assistant;
  List<PrayerAssignment> _selectedPrayers = [];
  bool _isVolunteer = true;
  bool _canReadArabic = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.muezzin?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.muezzin?.lastName ?? '');
    _arabicNameController =
        TextEditingController(text: widget.muezzin?.fullNameArabic ?? '');
    _phoneController = TextEditingController(text: widget.muezzin?.phone ?? '');
    _emailController = TextEditingController(text: widget.muezzin?.email ?? '');
    _voiceQualityController =
        TextEditingController(text: widget.muezzin?.voiceQuality ?? '');
    _trainingController =
        TextEditingController(text: widget.muezzin?.training ?? '');

    if (widget.muezzin != null) {
      _selectedStatus = widget.muezzin!.status;
      _selectedPrayers = List.from(widget.muezzin!.assignedPrayers);
      _isVolunteer = widget.muezzin!.isVolunteer;
      _canReadArabic = widget.muezzin!.canReadArabic;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _arabicNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _voiceQualityController.dispose();
    _trainingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.muezzin == null ? Icons.person_add : Icons.edit,
                  color: Colors.indigo,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.muezzin == null
                        ? 'Ajouter un Muezzin'
                        : 'Modifier le Muezzin',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Formulaire
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Prénom *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.trim().isEmpty == true
                                      ? 'Requis'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.trim().isEmpty == true
                                      ? 'Requis'
                                      : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _arabicNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom en arabe *',
                          border: OutlineInputBorder(),
                        ),
                        textDirection: TextDirection.rtl,
                        validator: (value) =>
                            value?.trim().isEmpty == true ? 'Requis' : null,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<MuezzinStatus>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Statut *',
                                border: OutlineInputBorder(),
                              ),
                              items: MuezzinStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(_getStatusDisplayName(status)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _isVolunteer,
                                  onChanged: (value) {
                                    setState(() {
                                      _isVolunteer = value!;
                                    });
                                  },
                                ),
                                const Text('Bénévole'),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _voiceQualityController,
                        decoration: const InputDecoration(
                          labelText: 'Qualité vocale',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _trainingController,
                        decoration: const InputDecoration(
                          labelText: 'Formation',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Prières assignées
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prières assignées',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: PrayerAssignment.values.map((prayer) {
                                final isSelected =
                                    _selectedPrayers.contains(prayer);
                                return FilterChip(
                                  label: Text(_getPrayerDisplayName(prayer)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedPrayers.add(prayer);
                                      } else {
                                        _selectedPrayers.remove(prayer);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Checkbox(
                            value: _canReadArabic,
                            onChanged: (value) {
                              setState(() {
                                _canReadArabic = value!;
                              });
                            },
                          ),
                          const Text('Peut lire l\'arabe'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveMuezzin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sauvegarder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(MuezzinStatus status) {
    switch (status) {
      case MuezzinStatus.principal:
        return 'Muezzin Principal';
      case MuezzinStatus.assistant:
        return 'Muezzin Assistant';
      case MuezzinStatus.remplacant:
        return 'Muezzin Remplaçant';
    }
  }

  String _getPrayerDisplayName(PrayerAssignment prayer) {
    switch (prayer) {
      case PrayerAssignment.fajr:
        return 'Fajr';
      case PrayerAssignment.dhuhr:
        return 'Dhuhr';
      case PrayerAssignment.asr:
        return 'Asr';
      case PrayerAssignment.maghrib:
        return 'Maghrib';
      case PrayerAssignment.isha:
        return 'Isha';
      case PrayerAssignment.jumma:
        return 'Vendredi';
      case PrayerAssignment.eid:
        return 'Aïd';
      case PrayerAssignment.all:
        return 'Toutes';
    }
  }

  Future<void> _saveMuezzin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPrayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une prière'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      final muezzin = Muezzin(
        id: widget.muezzin?.id ?? '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        fullNameArabic: _arabicNameController.text.trim(),
        status: _selectedStatus,
        assignedPrayers: _selectedPrayers,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        voiceQuality: _voiceQualityController.text.trim().isNotEmpty
            ? _voiceQualityController.text.trim()
            : null,
        training: _trainingController.text.trim().isNotEmpty
            ? _trainingController.text.trim()
            : null,
        isActive: true,
        isVolunteer: _isVolunteer,
        canReadArabic: _canReadArabic,
        languages: const ['Français', 'Arabe'],
        startDate: widget.muezzin?.startDate ?? now,
        createdAt: widget.muezzin?.createdAt ?? now,
        updatedAt: now,
        createdBy: widget.muezzin?.createdBy ?? 'admin',
      );

      if (widget.muezzin == null) {
        await _muezzinService.createMuezzin(muezzin);
      } else {
        await _muezzinService.updateMuezzin(muezzin);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.muezzin == null
                ? 'Muezzin ajouté avec succès'
                : 'Muezzin modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
