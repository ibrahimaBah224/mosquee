import 'package:flutter/material.dart';

class PaymentMethods extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethods({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  // Méthodes de paiement par défaut - configurables via l'interface admin
  static const List<Map<String, dynamic>> defaultPaymentMethods = [
    {
      'id': 'card',
      'name': 'Carte bancaire',
      'description': 'Visa, Mastercard, American Express',
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'enabled': true,
    },
    {
      'id': 'paypal',
      'name': 'PayPal',
      'description': 'Paiement sécurisé avec PayPal',
      'icon': Icons.payment,
      'color': Colors.indigo,
      'enabled': true,
    },
    {
      'id': 'bank_transfer',
      'name': 'Virement bancaire',
      'description': 'Virement direct sur compte bancaire',
      'icon': Icons.account_balance,
      'color': Colors.green,
      'enabled': true,
    },
    {
      'id': 'mobile_money',
      'name': 'Mobile Money',
      'description': 'Orange Money, MTN Money',
      'icon': Icons.phone_android,
      'color': Colors.orange,
      'enabled': true,
    },
    {
      'id': 'cash',
      'name': 'Espèces',
      'description': 'Don en espèces à la mosquée',
      'icon': Icons.payments,
      'color': Colors.brown,
      'enabled': true,
    },
    {
      'id': 'check',
      'name': 'Chèque',
      'description': 'Chèque à l\'ordre de la mosquée',
      'icon': Icons.receipt_long,
      'color': Colors.purple,
      'enabled': false, // Désactivé par défaut
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtrer les méthodes activées
    final enabledMethods = defaultPaymentMethods
        .where((method) => method['enabled'] == true)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enabledMethods.length,
          itemBuilder: (context, index) {
            final method = enabledMethods[index];
            final isSelected = selectedMethod == method['id'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onMethodSelected(method['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? method['color'].withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? method['color'] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: method['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          method['icon'],
                          color: method['color'],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? method['color']
                                    : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              method['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: method['color'],
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Note informative
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sécurité garantie',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Tous les paiements sont sécurisés et chiffrés.',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Méthode utilitaire pour obtenir le nom d'affichage d'une méthode
  static String getMethodDisplayName(String methodId) {
    final method = defaultPaymentMethods.firstWhere(
      (m) => m['id'] == methodId,
      orElse: () => {'name': methodId},
    );
    return method['name'];
  }

  /// Méthode utilitaire pour obtenir l'icône d'une méthode
  static IconData getMethodIcon(String methodId) {
    final method = defaultPaymentMethods.firstWhere(
      (m) => m['id'] == methodId,
      orElse: () => {'icon': Icons.payment},
    );
    return method['icon'];
  }

  /// Méthode utilitaire pour obtenir la couleur d'une méthode
  static Color getMethodColor(String methodId) {
    final method = defaultPaymentMethods.firstWhere(
      (m) => m['id'] == methodId,
      orElse: () => {'color': Colors.grey},
    );
    return method['color'];
  }

  /// Vérifier si une méthode est activée
  static bool isMethodEnabled(String methodId) {
    final method = defaultPaymentMethods.firstWhere(
      (m) => m['id'] == methodId,
      orElse: () => {'enabled': false},
    );
    return method['enabled'] ?? false;
  }
}
