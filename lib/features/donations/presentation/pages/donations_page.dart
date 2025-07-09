import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/donation_categories.dart';
import '../../../../core/models/mosque_info.dart';
import '../../../../core/services/mosque_service.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  String _selectedCategory = 'masjid'; // Utiliser l'ID plutôt que le nom
  String _orangeMoneyNumber = '+224 628 XX XX XX'; // Valeur par défaut
  String _mosqueName = 'Mosquée';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMosqueInfo();
  }

  Future<void> _loadMosqueInfo() async {
    try {
      final mosqueInfo = await MosqueService().getMosqueInfo();
      if (mosqueInfo != null) {
        setState(() {
          _orangeMoneyNumber =
              mosqueInfo.mobileMoneyNumber ?? '+224 628 XX XX XX';
          _mosqueName = mosqueInfo.name;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dons et Sadaqat'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dons et Sadaqat'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verset coranique sur la charité
            Card(
              elevation: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      size: 48,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'مَثَلُ الَّذِينَ يُنْفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontFamily: 'Amiri',
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"Ceux qui dépensent leurs biens dans le sentier d\'Allah sont semblables à un grain qui produit sept épis, et dans chaque épi cent grains. Allah multiplie pour qui Il veut."',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.green.shade700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sourate Al-Baqarah, verset 261',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rappel islamique sur les dons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Rappel Important',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'En Islam, les dons doivent être faits sincèrement pour Allah (SWT) uniquement. Il n\'est pas nécessaire de révéler votre identité ou le montant de votre don.',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Types de dons
            Text(
              'Types de contributions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
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

            // Informations sur la catégorie sélectionnée
            if (_selectedCategory.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DonationCategories.getCategoryColor(_selectedCategory)
                      .withOpacity(0.1),
                  border: Border.all(
                    color:
                        DonationCategories.getCategoryColor(_selectedCategory)
                            .withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      DonationCategories.getCategoryIcon(_selectedCategory),
                      color: DonationCategories.getCategoryColor(
                          _selectedCategory),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contribution sélectionnée',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            DonationCategories.getCategoryDisplayName(
                                _selectedCategory),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: DonationCategories.getCategoryColor(
                                  _selectedCategory),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Informations pour faire le don
            Card(
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Orange Money',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pour faire votre don, envoyez votre contribution sur :',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Numéro Orange Money',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _orangeMoneyNumber,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _mosqueName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _orangeMoneyNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Numéro copié dans le presse-papiers'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copier le numéro',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instructions détaillées
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Comment faire votre don',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      '1',
                      'Ouvrez votre application Orange Money',
                      Icons.phone_android,
                    ),
                    _buildInstructionStep(
                      '2',
                      'Sélectionnez "Transfert d\'argent"',
                      Icons.send_to_mobile,
                    ),
                    _buildInstructionStep(
                      '3',
                      'Entrez le numéro de la mosquée',
                      Icons.dialpad,
                    ),
                    _buildInstructionStep(
                      '4',
                      'Saisissez le montant souhaité',
                      Icons.attach_money,
                    ),
                    _buildInstructionStep(
                      '5',
                      'Confirmez la transaction',
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Messages d'encouragement islamiques
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.purple.shade700,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'بارك الله فيك',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                      fontFamily: 'Amiri',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barakallahu feek',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qu\'Allah vous récompense pour votre générosité et multiplie vos bienfaits.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Note sur l'anonymat
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anonymat respecté',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vos dons sont anonymes. Nous ne gardons aucune trace de qui a donné quoi, conformément aux enseignements islamiques.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
      String number, String instruction, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
