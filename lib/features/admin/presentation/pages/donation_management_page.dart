import 'package:flutter/material.dart';
import '../../../../core/models/donation.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/di/dependency_injection.dart';

class DonationManagementPage extends StatefulWidget {
  const DonationManagementPage({super.key});

  @override
  State<DonationManagementPage> createState() => _DonationManagementPageState();
}

class _DonationManagementPageState extends State<DonationManagementPage> {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  bool _isLoading = false;
  List<Donation> _donations = [];
  List<DonationCampaign> _campaigns = [];
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadDonations();
    _loadCampaigns();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implémenter getAllDonations dans FirestoreService
      setState(() {
        _donations = [];
      });
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCampaigns() async {
    try {
      // Les campagnes sont déjà gérées par watchActiveCampaigns
    } catch (e) {
      print('Erreur chargement campagnes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des Dons'),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.monetization_on), text: 'Dons'),
              Tab(icon: Icon(Icons.campaign), text: 'Campagnes'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addCampaign,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDonationsTab(),
            _buildCampaignsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsTab() {
    return Column(
      children: [
        // Statistiques des dons
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_donations.length}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Text('Total Dons'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_getTotalAmount().toStringAsFixed(0)}€',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Text('Montant Total'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_donations.where((d) => d.status == DonationStatus.completed).length}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Text('Validés'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Filtrer: '),
              DropdownButton<String>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'Tous', child: Text('Tous')),
                  DropdownMenuItem(value: 'completed', child: Text('Validés')),
                  DropdownMenuItem(value: 'pending', child: Text('En attente')),
                  DropdownMenuItem(value: 'failed', child: Text('Échoués')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
            ],
          ),
        ),

        // Liste des dons
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDonations.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monetization_on_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucun don trouvé',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredDonations.length,
                      itemBuilder: (context, index) {
                        final donation = _filteredDonations[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(donation.status),
                              child: Text(
                                '${donation.amount.toInt()}€',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(donation.donorName.isNotEmpty
                                ? donation.donorName
                                : 'Donateur anonyme'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${donation.amount}€ - ${donation.type.name}'),
                                Text(
                                  '${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(donation.status.name),
                              backgroundColor: _getStatusColor(donation.status)
                                  .withOpacity(0.2),
                            ),
                            onTap: () => _showDonationDetails(donation),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCampaignsTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<DonationCampaign>>(
            stream: _firestoreService.watchActiveCampaigns(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur: ${snapshot.error}'),
                );
              }

              final campaigns = snapshot.data ?? [];

              if (campaigns.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune campagne active',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = campaigns[index];
                  final progress = campaign.targetAmount > 0
                      ? campaign.currentAmount / campaign.targetAmount
                      : 0.0;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(campaign.description),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1.0 ? Colors.green : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${campaign.currentAmount.toInt()}€ / ${campaign.targetAmount.toInt()}€',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: progress >= 1.0
                                      ? Colors.green
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Donation> get _filteredDonations {
    if (_selectedFilter == 'Tous') return _donations;
    return _donations.where((donation) {
      return donation.status.name == _selectedFilter;
    }).toList();
  }

  double _getTotalAmount() {
    return _donations.fold(0.0, (sum, donation) => sum + donation.amount);
  }

  Color _getStatusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.completed:
        return Colors.green;
      case DonationStatus.pending:
        return Colors.orange;
      case DonationStatus.failed:
        return Colors.red;
      case DonationStatus.refunded:
        return Colors.grey;
    }
  }

  void _showDonationDetails(Donation donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Don de ${donation.amount}€'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Donateur: ${donation.donorName.isNotEmpty ? donation.donorName : "Anonyme"}'),
            Text('Email: ${donation.donorEmail ?? "Non renseigné"}'),
            Text('Type: ${donation.type.name}'),
            Text('Statut: ${donation.status.name}'),
            Text(
                'Date: ${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}'),
            if (donation.message?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              const Text('Message:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(donation.message!),
            ],
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

  void _addCampaign() {
    // TODO: Implémenter l'ajout de campagne
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Fonctionnalité d\'ajout de campagne à implémenter')),
    );
  }
}
