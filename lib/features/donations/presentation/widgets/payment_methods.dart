import 'package:flutter/material.dart';

class PaymentMethods extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethods({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  static const List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'card',
      'name': 'Carte Bancaire',
      'icon': Icons.credit_card,
      'description': 'Visa, Mastercard, Amex',
      'color': Colors.blue,
    },
    {
      'id': 'paypal',
      'name': 'PayPal',
      'icon': Icons.payment,
      'description': 'Paiement sécurisé',
      'color': Colors.indigo,
    },
    {
      'id': 'apple_pay',
      'name': 'Apple Pay',
      'icon': Icons.phone_iphone,
      'description': 'Touch ID / Face ID',
      'color': Colors.black,
    },
    {
      'id': 'google_pay',
      'name': 'Google Pay',
      'icon': Icons.android,
      'description': 'Paiement rapide',
      'color': Colors.green,
    },
    {
      'id': 'bank_transfer',
      'name': 'Virement Bancaire',
      'icon': Icons.account_balance,
      'description': 'Transfer direct',
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paymentMethods.length,
          itemBuilder: (context, index) {
            final method = paymentMethods[index];
            final isSelected = selectedMethod == method['id'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onMethodSelected(method['id']),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? method['color'].withOpacity(0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? method['color'] : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: method['color'].withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Payment Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? method['color']
                                    : method['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method['icon'],
                            color: isSelected ? Colors.white : method['color'],
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Method Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? method['color']
                                          : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selection Indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected
                                    ? method['color']
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? method['color']
                                      : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child:
                              isSelected
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Security Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tous les paiements sont sécurisés et cryptés. Vos données bancaires ne sont jamais stockées.',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
