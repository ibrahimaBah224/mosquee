import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Liste', icon: Icon(Icons.list)),
            Tab(text: 'Calendrier', icon: Icon(Icons.calendar_month)),
          ],
        ),
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
        const Padding(padding: EdgeInsets.all(16), child: EventSearchBar()),

        // Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: EventFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
        ),

        // Liste des événements
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10, // Remplacer par la vraie data
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EventCard(
                  title: 'Cours de Coran pour enfants',
                  description:
                      'Apprentissage de la récitation et de la mémorisation du Coran pour les enfants de 6 à 12 ans.',
                  date: DateTime.now().add(Duration(days: index)),
                  location: 'Salle 1 - Mosquée Al-Nour',
                  category: 'Éducation',
                  imageUrl: 'assets/images/coran_course.jpg',
                  isRegistered: index % 3 == 0,
                  onTap: () {
                    Navigator.of(context).pushNamed('/events/detail/$index');
                  },
                  onRegister: () {
                    _showRegistrationDialog(context);
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
    return Column(
      children: [
        // Calendrier
        TableCalendar(
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
          // Ajouter les événements comme markers
          eventLoader: (day) {
            // Retourner la liste des événements pour ce jour
            return []; // Remplacer par la vraie data
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3, // Remplacer par la vraie data
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text('${9 + index}h'),
                          ),
                          title: const Text('Cours d\'arabe'),
                          subtitle: const Text('Salle 2'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/events/detail/$index');
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
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Inscription à l\'événement'),
            content: const Text('Voulez-vous vous inscrire à cet événement ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inscription confirmée')),
                  );
                },
                child: const Text('S\'inscrire'),
              ),
            ],
          ),
    );
  }
}
