import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/imam.dart';
import '../../../../core/services/imam_service.dart';
import '../../../../core/widgets/cloudinary_image.dart';

class ImamManagementPage extends StatefulWidget {
  const ImamManagementPage({super.key});

  @override
  State<ImamManagementPage> createState() => _ImamManagementPageState();
}

class _ImamManagementPageState extends State<ImamManagementPage> {
  final ImamService _imamService = ImamService();
  final TextEditingController _searchController = TextEditingController();

  List<Imam> _imams = [];
  List<Imam> _filteredImams = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadImams();
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
      _filterImams();
    });
  }

  void _filterImams() {
    if (_searchQuery.isEmpty) {
      _filteredImams = List.from(_imams);
    } else {
      _filteredImams = _imams.where((imam) {
        final query = _searchQuery.toLowerCase();
        return imam.firstName.toLowerCase().contains(query) ||
            imam.lastName.toLowerCase().contains(query) ||
            imam.fullNameArabic.toLowerCase().contains(query) ||
            imam.rankDisplayName.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _loadImams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imams = await _imamService.getAllImams();
      setState(() {
        _imams = imams;
        _filterImams();
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

  Future<void> _deleteImam(Imam imam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'Imam ${imam.fullName} ?'),
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
        await _imamService.deleteImam(imam.id);
        _loadImams();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imam supprimé avec succès'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Imams'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadImams,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddImamDialog(),
            tooltip: 'Ajouter un Imam',
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
                colors: [Colors.teal, Colors.teal.shade700],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Imams',
                        '${_imams.length}',
                        Icons.people,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Imam Principal',
                        _imams
                            .where((i) => i.rank == ImamRank.principal)
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
                        _imams.where((i) => i.isActive).length.toString(),
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
                    hintText: 'Rechercher un Imam...',
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

          // Liste des Imams
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredImams.isEmpty
                    ? _buildEmptyState()
                    : _buildImamsList(),
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
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun Imam trouvé pour "$_searchQuery"'
                : 'Aucun Imam enregistré',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Essayez avec d\'autres mots-clés'
                : 'Ajoutez votre premier Imam',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddImamDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un Imam'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImamsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredImams.length,
      itemBuilder: (context, index) {
        final imam = _filteredImams[index];
        return _buildImamCard(imam);
      },
    );
  }

  Widget _buildImamCard(Imam imam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showImamDetails(imam),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar ou icône
                  CloudinaryAvatar(
                    publicId: imam.photoUrl ?? '',
                    radius: 30,
                    backgroundColor: _getRankColor(imam.rank),
                    fallbackIcon: Icons.person,
                  ),
                  const SizedBox(width: 16),

                  // Informations principales
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                imam.fullName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRankColor(imam.rank),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${imam.orderInHierarchy}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          imam.fullNameArabic,
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
                                color:
                                    _getRankColor(imam.rank).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _getRankColor(imam.rank)
                                        .withOpacity(0.3)),
                              ),
                              child: Text(
                                imam.rankDisplayName,
                                style: TextStyle(
                                  color: _getRankColor(imam.rank),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (imam.hasContact) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.contact_phone,
                                size: 16,
                                color: Colors.green[600],
                              ),
                            ],
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
                          _showEditImamDialog(imam);
                          break;
                        case 'delete':
                          _deleteImam(imam);
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

              // Spécialités
              if (imam.specialties.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: imam.specialtyDisplayNames.take(3).map((specialty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        specialty,
                        style: TextStyle(
                          color: Colors.blue[700],
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
                  if (imam.age != null) ...[
                    Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${imam.age} ans',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (imam.serviceYears != null) ...[
                    Icon(Icons.work, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${imam.serviceYears!.inDays ~/ 365} ans de service',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
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

  void _showImamDetails(Imam imam) {
    showDialog(
      context: context,
      builder: (context) => _ImamDetailsDialog(imam: imam),
    );
  }

  void _showAddImamDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddEditImamDialog(
        onSaved: () {
          _loadImams();
        },
      ),
    );
  }

  void _showEditImamDialog(Imam imam) {
    showDialog(
      context: context,
      builder: (context) => _AddEditImamDialog(
        imam: imam,
        onSaved: () {
          _loadImams();
        },
      ),
    );
  }
}

// Dialog pour afficher les détails d'un Imam
class _ImamDetailsDialog extends StatelessWidget {
  final Imam imam;

  const _ImamDetailsDialog({required this.imam});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                CloudinaryAvatar(
                  publicId: imam.photoUrl ?? '',
                  radius: 30,
                  backgroundColor: _getRankColor(imam.rank),
                  fallbackIcon: Icons.person,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        imam.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        imam.fullNameArabic,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRankColor(imam.rank),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          imam.rankDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Contact', [
                      if (imam.phone?.isNotEmpty == true)
                        _buildDetailRow('Téléphone', imam.phone!, Icons.phone),
                      if (imam.email?.isNotEmpty == true)
                        _buildDetailRow('Email', imam.email!, Icons.email),
                      if (imam.address?.isNotEmpty == true)
                        _buildDetailRow(
                            'Adresse', imam.address!, Icons.location_on),
                    ]),
                    _buildDetailSection('Formation', [
                      if (imam.education?.isNotEmpty == true)
                        _buildDetailRow(
                            'Éducation', imam.education!, Icons.school),
                      if (imam.certifications?.isNotEmpty == true)
                        _buildDetailRow('Certifications', imam.certifications!,
                            Icons.verified),
                      _buildDetailRow(
                          'Langues', imam.languages.join(', '), Icons.language),
                    ]),
                    if (imam.specialties.isNotEmpty)
                      _buildDetailSection('Spécialités', [
                        _buildDetailRow('Domaines',
                            imam.specialtyDisplayNames.join(', '), Icons.star),
                      ]),
                    if (imam.biography?.isNotEmpty == true)
                      _buildDetailSection('Biographie', [
                        Text(
                          imam.biography!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ]),
                  ],
                ),
              ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog pour ajouter/modifier un Imam
class _AddEditImamDialog extends StatefulWidget {
  final Imam? imam;
  final VoidCallback onSaved;

  const _AddEditImamDialog({
    this.imam,
    required this.onSaved,
  });

  @override
  State<_AddEditImamDialog> createState() => _AddEditImamDialogState();
}

class _AddEditImamDialogState extends State<_AddEditImamDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImamService _imamService = ImamService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _arabicNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _educationController;
  late TextEditingController _biographyController;

  ImamRank _selectedRank = ImamRank.assistant;
  int _orderInHierarchy = 1;
  List<ImamSpecialty> _selectedSpecialties = [];
  bool _isLoading = false;
  String? _photoUrl; // Ajout du champ photo

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.imam?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.imam?.lastName ?? '');
    _arabicNameController =
        TextEditingController(text: widget.imam?.fullNameArabic ?? '');
    _phoneController = TextEditingController(text: widget.imam?.phone ?? '');
    _emailController = TextEditingController(text: widget.imam?.email ?? '');
    _addressController =
        TextEditingController(text: widget.imam?.address ?? '');
    _educationController =
        TextEditingController(text: widget.imam?.education ?? '');
    _biographyController =
        TextEditingController(text: widget.imam?.biography ?? '');

    if (widget.imam != null) {
      _selectedRank = widget.imam!.rank;
      _orderInHierarchy = widget.imam!.orderInHierarchy;
      _selectedSpecialties = List.from(widget.imam!.specialties);
      _photoUrl = widget.imam!.photoUrl; // Initialiser la photo existante
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _arabicNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _educationController.dispose();
    _biographyController.dispose();
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
                  widget.imam == null ? Icons.person_add : Icons.edit,
                  color: Colors.teal,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.imam == null
                        ? 'Ajouter un Imam'
                        : 'Modifier l\'Imam',
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
                      // Photo de profil
                      Center(
                        child: ProfileImageUploader(
                          initialImageUrl: _photoUrl,
                          onImageUploaded: (publicId) {
                            setState(() {
                              _photoUrl = publicId;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

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
                            child: DropdownButtonFormField<ImamRank>(
                              value: _selectedRank,
                              decoration: const InputDecoration(
                                labelText: 'Rang *',
                                border: OutlineInputBorder(),
                              ),
                              items: ImamRank.values.map((rank) {
                                return DropdownMenuItem(
                                  value: rank,
                                  child: Text(_getRankDisplayName(rank)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRank = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _orderInHierarchy.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Ordre hiérarchique *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final num = int.tryParse(value ?? '');
                                return num == null || num < 1
                                    ? 'Nombre requis'
                                    : null;
                              },
                              onChanged: (value) {
                                _orderInHierarchy = int.tryParse(value) ?? 1;
                              },
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
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _educationController,
                        decoration: const InputDecoration(
                          labelText: 'Formation/Éducation',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Spécialités
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
                              'Spécialités',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ImamSpecialty.values.map((specialty) {
                                final isSelected =
                                    _selectedSpecialties.contains(specialty);
                                return FilterChip(
                                  label:
                                      Text(_getSpecialtyDisplayName(specialty)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedSpecialties.add(specialty);
                                      } else {
                                        _selectedSpecialties.remove(specialty);
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

                      TextFormField(
                        controller: _biographyController,
                        decoration: const InputDecoration(
                          labelText: 'Biographie',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
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
                  onPressed: _isLoading ? null : _saveImam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
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

  String _getRankDisplayName(ImamRank rank) {
    switch (rank) {
      case ImamRank.principal:
        return 'Imam Principal';
      case ImamRank.adjoint:
        return 'Imam Adjoint';
      case ImamRank.assistant:
        return 'Imam Assistant';
      case ImamRank.visiteur:
        return 'Imam Visiteur';
    }
  }

  String _getSpecialtyDisplayName(ImamSpecialty specialty) {
    switch (specialty) {
      case ImamSpecialty.khutba:
        return 'Prêche du vendredi';
      case ImamSpecialty.tarawih:
        return 'Prières de Tarawih';
      case ImamSpecialty.courses:
        return 'Cours et enseignement';
      case ImamSpecialty.marriage:
        return 'Mariages religieux';
      case ImamSpecialty.funeral:
        return 'Services funéraires';
      case ImamSpecialty.general:
        return 'Services généraux';
    }
  }

  Future<void> _saveImam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      final imam = Imam(
        id: widget.imam?.id ?? '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        fullNameArabic: _arabicNameController.text.trim(),
        rank: _selectedRank,
        orderInHierarchy: _orderInHierarchy,
        specialties: _selectedSpecialties,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        photoUrl: _photoUrl, // Ajout de l'URL de la photo
        education: _educationController.text.trim().isNotEmpty
            ? _educationController.text.trim()
            : null,
        biography: _biographyController.text.trim().isNotEmpty
            ? _biographyController.text.trim()
            : null,
        languages: const ['Français', 'Arabe'],
        isActive: true,
        startDate: widget.imam?.startDate ?? now,
        createdAt: widget.imam?.createdAt ?? now,
        updatedAt: now,
        createdBy: widget.imam?.createdBy ?? 'admin',
      );

      if (widget.imam == null) {
        await _imamService.createImam(imam);
      } else {
        await _imamService.updateImam(imam);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.imam == null
                ? 'Imam ajouté avec succès'
                : 'Imam modifié avec succès'),
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
