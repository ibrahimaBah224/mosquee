import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/donation_amount_selector.dart';
import '../widgets/donation_categories.dart';
import '../widgets/donation_history_card.dart';
import '../widgets/payment_methods.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _selectedAmount = 0;
  String _selectedCategory = 'Zakat';
  String _selectedPaymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Dons et Sadaqat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Faire un don', icon: Icon(Icons.volunteer_activism)),
            Tab(text: 'Mes dons', icon: Icon(Icons.history)),
            Tab(text: 'Objectifs', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDonationForm(),
          _buildDonationHistory(),
          _buildDonationGoals(),
        ],
      ),
    );
  }

  Widget _buildDonationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verset coranique sur la charité
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'مَثَلُ الَّذِينَ يُنْفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontFamily: 'Amiri'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Ceux qui dépensent leurs biens dans le sentier d\'Allah sont semblables à un grain..."',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sourate Al-Baqarah, verset 261',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Catégories de dons
          Text('Type de don', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DonationCategories(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          const SizedBox(height: 24),

          // Sélecteur de montant
          Text(
            'Montant du don',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DonationAmountSelector(
            selectedAmount: _selectedAmount,
            onAmountChanged: (amount) {
              setState(() {
                _selectedAmount = amount;
              });
            },
          ),

          const SizedBox(height: 24),

          // Méthodes de paiement
          Text(
            'Méthode de paiement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          PaymentMethods(
            selectedMethod: _selectedPaymentMethod,
            onMethodSelected: (method) {
              setState(() {
                _selectedPaymentMethod = method;
              });
            },
          ),

          const SizedBox(height: 32),

          // Bouton de don
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAmount > 0 ? _processDonation : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Faire un don de ${_selectedAmount.toStringAsFixed(0)}€',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Note sur la sécurité
          Card(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.security, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vos paiements sont sécurisés et cryptés. Vous recevrez un reçu fiscal.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Remplacer par la vraie data
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DonationHistoryCard(
            amount: (50 + index * 25).toDouble(),
            category: index % 2 == 0 ? 'Zakat' : 'Sadaqah',
            date: DateTime.now().subtract(Duration(days: index * 30)),
            reference: 'TXN${DateTime.now().millisecondsSinceEpoch + index}',
            status: 'Confirmé',
          ),
        );
      },
    );
  }

  Widget _buildDonationGoals() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques globales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistiques des dons',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Graphique des dons par mois
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        // Configuration du graphique
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 1000),
                              const FlSpot(1, 1500),
                              const FlSpot(2, 1200),
                              const FlSpot(3, 1800),
                              const FlSpot(4, 2200),
                              const FlSpot(5, 2000),
                            ],
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Objectifs en cours
          Text(
            'Objectifs en cours',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          ...List.generate(3, (index) {
            final goals = [
              {
                'title': 'Rénovation de la mosquée',
                'current': 15000,
                'target': 25000,
              },
              {
                'title': 'Aide aux familles nécessiteuses',
                'current': 8000,
                'target': 12000,
              },
              {
                'title': 'Achat de nouveaux tapis de prière',
                'current': 2500,
                'target': 3500,
              },
            ];
            final goal = goals[index];
            final progress = (goal['current'] as int) / (goal['target'] as int);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${goal['current']}€'),
                        Text('${goal['target']}€'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}% atteint',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _processDonation() {
    // Logique de traitement du don
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer le don'),
            content: Text(
              'Vous allez faire un don de ${_selectedAmount.toStringAsFixed(0)}€ '
              'pour $_selectedCategory via $_selectedPaymentMethod.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showPaymentDialog();
                },
                child: const Text('Confirmer'),
              ),
            ],
          ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Traitement du paiement'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Veuillez patienter...'),
              ],
            ),
          ),
    );

    // Simuler le traitement
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Don effectué avec succès. Merci !'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedAmount = 0;
      });
    });
  }
}
