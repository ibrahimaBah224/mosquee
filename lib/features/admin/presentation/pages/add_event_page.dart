import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/event.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _organizerController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay(
    hour: (TimeOfDay.now().hour + 2) % 24,
    minute: TimeOfDay.now().minute,
  );
  EventCategory _selectedCategory = EventCategory.community;
  EventStatus _selectedStatus = EventStatus.published;
  bool _isFree = true;
  bool _requiresRegistration = false;
  int _maxParticipants = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _organizerController.text = 'Mosquée Elhadj Daouda'; // Valeur par défaut
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel Événement'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child:
                            const Icon(Icons.event_note, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Créer un événement',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Ajoutez les détails de votre événement',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Informations de base
              _buildSectionCard(
                'Informations générales',
                [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre de l\'événement *',
                      hintText: 'Ex: Cours de Coran pour débutants',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le titre est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Décrivez votre événement...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La description est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _organizerController,
                    decoration: const InputDecoration(
                      labelText: 'Organisateur *',
                      hintText: 'Nom de l\'organisateur',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'organisateur est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EventCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: EventCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_getCategoryName(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Dates et heures
              _buildSectionCard(
                'Dates et heures',
                [
                  // Date et heure de début
                  Text(
                    'Début de l\'événement',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Date'),
                          subtitle: Text(
                            '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                          ),
                          leading: const Icon(Icons.calendar_today),
                          onTap: () => _selectStartDate(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ListTile(
                          title: const Text('Heure'),
                          subtitle: Text(_selectedStartTime.format(context)),
                          leading: const Icon(Icons.access_time),
                          onTap: () => _selectStartTime(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date et heure de fin
                  Text(
                    'Fin de l\'événement',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Date'),
                          subtitle: Text(
                            '${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year}',
                          ),
                          leading: const Icon(Icons.calendar_today),
                          onTap: () => _selectEndDate(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ListTile(
                          title: const Text('Heure'),
                          subtitle: Text(_selectedEndTime.format(context)),
                          leading: const Icon(Icons.access_time),
                          onTap: () => _selectEndTime(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Lieu
              _buildSectionCard(
                'Localisation',
                [
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lieu *',
                      hintText: 'Ex: Salle de prière principale',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le lieu est obligatoire';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Paramètres d'inscription
              _buildSectionCard(
                'Inscription et participation',
                [
                  SwitchListTile(
                    title: const Text('Inscription requise'),
                    subtitle:
                        const Text('Les participants doivent s\'inscrire'),
                    value: _requiresRegistration,
                    onChanged: (value) {
                      setState(() {
                        _requiresRegistration = value;
                      });
                    },
                  ),
                  if (_requiresRegistration) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _maxParticipants.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Nombre maximum de participants',
                        hintText: '0 = illimité',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _maxParticipants = int.tryParse(value) ?? 0;
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Prix
              _buildSectionCard(
                'Tarification',
                [
                  SwitchListTile(
                    title: const Text('Événement gratuit'),
                    subtitle:
                        const Text('L\'événement ne nécessite pas de paiement'),
                    value: _isFree,
                    onChanged: (value) {
                      setState(() {
                        _isFree = value;
                        if (_isFree) {
                          _priceController.clear();
                        }
                      });
                    },
                  ),
                  if (!_isFree) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Prix (GNF)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Statut
              _buildSectionCard(
                'Publication',
                [
                  DropdownButtonFormField<EventStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Statut de l\'événement',
                      prefixIcon: Icon(Icons.info),
                    ),
                    items: EventStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusName(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Créer l\'événement'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _getCategoryName(EventCategory category) {
    switch (category) {
      case EventCategory.religious:
        return 'Religieux';
      case EventCategory.educational:
        return 'Éducation/Formation';
      case EventCategory.community:
        return 'Communautaire';
      case EventCategory.fundraising:
        return 'Collecte de fonds';
      case EventCategory.social:
        return 'Social';
    }
  }

  String _getStatusName(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return 'Brouillon';
      case EventStatus.published:
        return 'Publié';
      case EventStatus.cancelled:
        return 'Annulé';
      case EventStatus.completed:
        return 'Terminé';
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        // Si la date de fin est avant la date de début, l'ajuster
        if (_selectedEndDate.isBefore(_selectedStartDate)) {
          _selectedEndDate = _selectedStartDate;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );

      final endDateTime = DateTime(
        _selectedEndDate.year,
        _selectedEndDate.month,
        _selectedEndDate.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );

      final event = Event(
        id: '', // Sera généré par Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        status: _selectedStatus,
        startDate: startDateTime,
        endDate: endDateTime,
        location: _locationController.text.trim(),
        organizer: _organizerController.text.trim(),
        maxParticipants: _requiresRegistration ? _maxParticipants : 0,
        currentParticipants: 0,
        requiresRegistration: _requiresRegistration,
        price: _isFree ? null : double.tryParse(_priceController.text),
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'admin', // TODO: Récupérer l'utilisateur connecté
      );

      await FirestoreService().createEvent(event);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/admin/events');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création : $e'),
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
