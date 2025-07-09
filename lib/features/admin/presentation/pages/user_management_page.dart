import 'package:flutter/material.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/di/dependency_injection.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  bool _isLoading = false;
  List<UserProfile> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implémenter getAllUsers dans FirestoreService
      // final users = await _firestoreService.getAllUsers();
      // setState(() {
      //   _users = users;
      // });

      // Pour l'instant, liste vide
      setState(() {
        _users = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un utilisateur',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Statistiques
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_users.length}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Text('Total Utilisateurs'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_users.where((u) => u.isActive).length}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Text('Actifs'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_users.where((u) => u.role == UserRole.admin).length}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Text('Admins'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Liste des utilisateurs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucun utilisateur trouvé',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Les utilisateurs apparaîtront ici après inscription',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? Text(user.displayName.isNotEmpty
                                        ? user.displayName[0].toUpperCase()
                                        : 'U')
                                    : null,
                              ),
                              title: Text(user.displayName.isNotEmpty
                                  ? user.displayName
                                  : 'Utilisateur sans nom'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  Text(
                                    'Rôle: ${user.role.name} • ${user.isActive ? "Actif" : "Inactif"}',
                                    style: TextStyle(
                                      color: user.isActive
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: ListTile(
                                      leading: Icon(Icons.visibility),
                                      title: Text('Voir détails'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Modifier'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: user.isActive
                                        ? 'deactivate'
                                        : 'activate',
                                    child: ListTile(
                                      leading: Icon(user.isActive
                                          ? Icons.block
                                          : Icons.check_circle),
                                      title: Text(user.isActive
                                          ? 'Désactiver'
                                          : 'Activer'),
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  _handleUserAction(user, value as String);
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  List<UserProfile> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      return user.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleUserAction(UserProfile user, String action) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
    }
  }

  void _showUserDetails(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Téléphone: ${user.phoneNumber ?? "Non renseigné"}'),
            Text('Rôle: ${user.role.name}'),
            Text('Statut: ${user.isActive ? "Actif" : "Inactif"}'),
            Text(
                'Inscrit le: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _editUser(UserProfile user) {
    // TODO: Implémenter l'édition d'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'édition à implémenter')),
    );
  }

  void _toggleUserStatus(UserProfile user) {
    // TODO: Implémenter l'activation/désactivation d'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            user.isActive ? 'Utilisateur désactivé' : 'Utilisateur activé'),
      ),
    );
  }
}
