import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/models/event.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../widgets/event_card.dart';
import '../widgets/event_filter_chips.dart';
import '../widgets/event_search_bar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedFilter = 'Tous';
  String _searchQuery = '';

  // Utiliser l'instance singleton du DI
  late final FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Récupérer l'instance singleton
    _firestoreService = getIt<FirestoreService>();
    print('🔧 EventsPage: Using singleton FirestoreService');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<Event> _filterEvents(List<Event> events) {
    List<Event> filteredEvents = events;

    // Filtrer par catégorie
    if (_selectedFilter != 'Tous') {
      filteredEvents = filteredEvents.where((event) {
        return event.category
            .toString()
            .toLowerCase()
            .contains(_selectedFilter.toLowerCase());
      }).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        return event.title.toLowerCase().contains(_searchQuery) ||
            event.description.toLowerCase().contains(_searchQuery) ||
            event.location.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filteredEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Liste'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendrier'),
          ],
        ),
        actions: [
          // Bouton de test direct
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () async {
              print('🧪 === TEST DIRECT FIRESTORE ===');
              try {
                // Test 1: getAllEvents
                final allEvents = await _firestoreService.getAllEvents();
                print('🧪 Test getAllEvents: ${allEvents.length} événements');

                // Test 2: watchPublishedEvents.first
                final publishedEvents =
                    await _firestoreService.watchPublishedEvents().first;
                print(
                    '🧪 Test watchPublished: ${publishedEvents.length} événements');

                // Afficher les résultats
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Test: ${allEvents.length} total, ${publishedEvents.length} stream'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('🧪 Erreur test: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            tooltip: 'Test Firestore',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEventsList(), _buildCalendarView()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers la création d'événement (pour les administrateurs)
          Navigator.of(context).pushNamed('/events/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList() {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: EventSearchBar(onSearchChanged: _onSearchChanged),
        ),

        // Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: EventFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),
        ),

        // Liste des événements
        Expanded(
          child: StreamBuilder<List<Event>>(
            stream: _firestoreService.watchPublishedEvents(),
            builder: (context, snapshot) {
              print('🔍 === DIAGNOSTIC COMPLET STREAMBUILDER ===');
              print('🔍 ConnectionState: ${snapshot.connectionState}');
              print('🔍 HasData: ${snapshot.hasData}');
              print('🔍 HasError: ${snapshot.hasError}');
              print('🔍 Data: ${snapshot.data}');
              print('🔍 Error: ${snapshot.error}');

              if (snapshot.hasData) {
                print('🔍 Events received: ${snapshot.data!.length}');
                for (var event in snapshot.data!) {
                  print(
                      '📋 Event in UI: ${event.title} - Status: ${event.status} - Date: ${event.startDate}');
                }
              }

              // Test simple : toujours afficher un widget de test
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('⏳ StreamBuilder: En attente...');
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Connexion à Firestore...'),
                      SizedBox(height: 8),
                      Text(
                        'Si cela prend trop de temps, vérifiez votre connexion',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                print('❌ StreamBuilder error: ${snapshot.error}');
                return _buildNetworkErrorState(snapshot.error.toString());
              }

              // DÉBOGAGE : Montrer les données brutes d'abord
              List<Event> events = snapshot.data ?? [];
              print('🔍 Raw events from snapshot: ${events.length}');

              if (events.isEmpty) {
                print('❌ PROBLÈME: Aucun événement reçu du Stream');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 64, color: Colors.orange),
                      SizedBox(height: 16),
                      Text('DEBUG: Stream vide',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Le Stream ne retourne aucun événement'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          print('🔄 Forçage du rebuild...');
                          setState(() {});
                        },
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              List<Event> filteredEvents = _filterEvents(events);

              print('🔍 Events after filtering: ${filteredEvents.length}');
              print('🔍 Current filter: $_selectedFilter');
              print('🔍 Current search: $_searchQuery');

              if (filteredEvents.isEmpty) {
                print('❌ PROBLÈME: Filtrage élimine tous les événements');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list_off, size: 64, color: Colors.blue),
                      SizedBox(height: 16),
                      Text('DEBUG: Filtre trop restrictif',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                          '${events.length} événements total, 0 après filtrage'),
                      Text('Filtre actuel: $_selectedFilter'),
                      Text('Recherche: "$_searchQuery"'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'Tous';
                            _searchQuery = '';
                          });
                        },
                        child: Text('Réinitialiser filtres'),
                      ),
                    ],
                  ),
                );
              }

              print('✅ Affichage de ${filteredEvents.length} événements');
              return RefreshIndicator(
                onRefresh: () async {
                  print('🔄 RefreshIndicator activé');
                  setState(() {}); // Force rebuild du StreamBuilder
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    print('🎯 Building EventCard for: ${event.title}');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EventCard(
                        title: event.title,
                        description: event.description,
                        date: event.startDate,
                        location: event.location,
                        category: event.category.toString().split('.').last,
                        imageUrl: event.imageUrl ?? '', // Support Cloudinary
                        isRegistered:
                            false, // TODO: Vérifier inscription utilisateur
                        onTap: () {
                          // TODO: Navigation vers les détails
                        },
                        onRegister: () {
                          _showRegistrationDialog(context, event);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    return StreamBuilder<List<Event>>(
      stream: _firestoreService.watchPublishedEvents(),
      builder: (context, snapshot) {
        print('📅 Calendar StreamBuilder state: ${snapshot.connectionState}');
        print('📅 Calendar StreamBuilder hasData: ${snapshot.hasData}');

        List<Event> allEvents = snapshot.data ?? [];
        print('📅 Calendar events received: ${allEvents.length}');

        Map<DateTime, List<Event>> eventsByDate = {};

        // Grouper les événements par date
        for (Event event in allEvents) {
          DateTime eventDate = DateTime(
            event.startDate.year,
            event.startDate.month,
            event.startDate.day,
          );
          if (eventsByDate[eventDate] == null) {
            eventsByDate[eventDate] = [];
          }
          eventsByDate[eventDate]!.add(event);
        }

        print('📅 Events grouped by ${eventsByDate.length} dates');

        List<Event> selectedDayEvents = eventsByDate[DateTime(
              _selectedDay.year,
              _selectedDay.month,
              _selectedDay.day,
            )] ??
            [];

        print('📅 Selected day events: ${selectedDayEvents.length}');

        return Column(
          children: [
            // Calendrier
            TableCalendar<Event>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              eventLoader: (day) {
                return eventsByDate[DateTime(day.year, day.month, day.day)] ??
                    [];
              },
            ),

            const Divider(),

            // Événements du jour sélectionné
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Événements du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: selectedDayEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun événement ce jour',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: selectedDayEvents.length,
                            itemBuilder: (context, index) {
                              final event = selectedDayEvents[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text(
                                        '${event.startDate.hour}h',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(event.title),
                                    subtitle: Text(event.location),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      // TODO: Navigation vers les détails
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun événement',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'Tous'
                ? 'Aucun résultat pour votre recherche.'
                : 'Les événements seront ajoutés par l\'administration.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erreur de connexion',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Force rebuild
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inscription à "${event.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous vous inscrire à cet événement ?'),
            const SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(event.startDate)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Lieu: ${event.location}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (event.maxParticipants != null)
              Text(
                'Places: ${event.currentParticipants}/${event.maxParticipants}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: event.maxParticipants != null &&
                    event.currentParticipants >= event.maxParticipants!
                ? null
                : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inscription confirmée')),
                    );
                    // TODO: Implémenter vraie logique d'inscription
                  },
            child: const Text('S\'inscrire'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
