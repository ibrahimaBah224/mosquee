import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/event.dart';
import '../../../../core/repositories/event_repository.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/firestore_service.dart';

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final EventRepository _eventRepository = getIt<EventRepository>();
  final FirestoreService _firestoreService = getIt<FirestoreService>();

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  EventStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      // Charger tous les événements avec stream
      _firestoreService.getAllEventsStream().listen((events) {
        setState(() {
          _allEvents = events;
          _filterEvents();
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _filterEvents() {
    if (_selectedStatusFilter == null) {
      _filteredEvents = List.from(_allEvents);
    } else {
      _filteredEvents = _allEvents
          .where((event) => event.status == _selectedStatusFilter)
          .toList();
    }

    // Trier par date de création (plus récent en premier)
    _filteredEvents.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> _changeEventStatus(Event event, EventStatus newStatus) async {
    try {
      await _firestoreService.updateEventStatus(event.id, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Statut changé vers ${_getStatusDisplayName(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du changement de statut: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent(String eventId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              const TextSpan(
                  text: 'Êtes-vous sûr de vouloir supprimer l\'événement '),
              TextSpan(
                text: '"$title"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' ? Cette action est irréversible.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteEvent(eventId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Événement supprimé avec succès'),
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
        title: const Text('Gestion des Événements'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEventForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Ajouter un événement',
      ),
      body: Column(
        children: [
          // Barre de filtres
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrer par statut:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text('Tous (${_allEvents.length})'),
                      selected: _selectedStatusFilter == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatusFilter = null;
                          _filterEvents();
                        });
                      },
                    ),
                    ...EventStatus.values.map((status) {
                      final count =
                          _allEvents.where((e) => e.status == status).length;
                      return FilterChip(
                        label:
                            Text('${_getStatusDisplayName(status)} ($count)'),
                        selected: _selectedStatusFilter == status,
                        selectedColor: _getStatusColor(status).withOpacity(0.3),
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatusFilter = selected ? status : null;
                            _filterEvents();
                          });
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Liste des événements
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedStatusFilter == null
                                  ? 'Aucun événement'
                                  : 'Aucun événement ${_getStatusDisplayName(_selectedStatusFilter!).toLowerCase()}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = _filteredEvents[index];
                          return _buildEventCard(event);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et statut
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusChip(event),
              ],
            ),

            const SizedBox(height: 12),

            // Informations détaillées
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),

            if (event.requiresRegistration) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${event.currentParticipants}/${event.maxParticipants} participants',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Catégorie et actions
            Row(
              children: [
                Chip(
                  label: Text(
                    event.category.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getCategoryColor(event.category),
                ),
                const Spacer(),

                // Menu de changement de statut
                PopupMenuButton<EventStatus>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Changer le statut',
                  onSelected: (status) => _changeEventStatus(event, status),
                  itemBuilder: (context) => EventStatus.values
                      .where((status) => status != event.status)
                      .map((status) => PopupMenuItem<EventStatus>(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    'Marquer comme ${_getStatusDisplayName(status).toLowerCase()}'),
                              ],
                            ),
                          ))
                      .toList(),
                ),

                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigateToEventForm(event: event),
                  tooltip: 'Modifier',
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteEvent(event.id, event.title),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Event event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(event.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusDisplayName(event.status).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusDisplayName(EventStatus status) {
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

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return Colors.grey;
      case EventStatus.published:
        return Colors.green;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.completed:
        return Colors.blue;
    }
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.religious:
        return Colors.purple[100]!;
      case EventCategory.educational:
        return Colors.blue[100]!;
      case EventCategory.community:
        return Colors.green[100]!;
      case EventCategory.fundraising:
        return Colors.orange[100]!;
      case EventCategory.social:
        return Colors.pink[100]!;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToEventForm({Event? event}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EventFormPage(event: event),
          ),
        )
        .then((_) => _loadEvents());
  }
}

// EventFormPage reste la même...
class EventFormPage extends StatefulWidget {
  final Event? event;

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _organizerController;
  late final TextEditingController _maxParticipantsController;
  late final TextEditingController _priceController;

  EventCategory _category = EventCategory.community;
  bool _requiresRegistration = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');
    _organizerController =
        TextEditingController(text: widget.event?.organizer ?? '');
    _maxParticipantsController = TextEditingController(
        text: widget.event?.maxParticipants.toString() ?? '50');
    _priceController =
        TextEditingController(text: widget.event?.price?.toString() ?? '');

    if (widget.event != null) {
      _category = widget.event!.category;
      _requiresRegistration = widget.event!.requiresRegistration;
      _startDate = widget.event!.startDate;
      _endDate = widget.event!.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null
            ? 'Nouvel Événement'
            : 'Modifier l\'Événement'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value?.isEmpty == true ? 'Description requise' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: EventCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Lieu requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(
                  labelText: 'Organisateur *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Organisateur requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_formatDateTime(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_formatDateTime(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Inscription requise'),
                value: _requiresRegistration,
                onChanged: (value) =>
                    setState(() => _requiresRegistration = value),
              ),
              if (_requiresRegistration) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxParticipantsController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre maximum de participants',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_requiresRegistration && (value?.isEmpty == true)) {
                      return 'Nombre requis si inscription requise';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix (optionnel)',
                  border: OutlineInputBorder(),
                  suffixText: '€',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.event == null
                              ? 'Créer l\'événement'
                              : 'Mettre à jour',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
      );

      if (time != null) {
        final newDate =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          if (isStart) {
            _startDate = newDate;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 2));
            }
          } else {
            _endDate = newDate;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final event = Event(
        id: widget.event?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text,
        organizer: _organizerController.text,
        requiresRegistration: _requiresRegistration,
        maxParticipants: _requiresRegistration
            ? int.parse(_maxParticipantsController.text)
            : 0,
        currentParticipants: widget.event?.currentParticipants ?? 0,
        price: _priceController.text.isNotEmpty
            ? double.parse(_priceController.text)
            : null,
        status: widget.event?.status ?? EventStatus.draft,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.event?.createdBy ?? 'admin', // Admin par défaut
      );

      if (widget.event == null) {
        await _firestoreService.createEvent(event);
      } else {
        await _firestoreService.updateEvent(event);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.event == null
                ? 'Événement créé avec succès'
                : 'Événement mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
