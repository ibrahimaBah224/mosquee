import 'package:flutter/material.dart';

class DonationAmountSelector extends StatefulWidget {
  final Function(double) onAmountChanged;
  final double? selectedAmount;

  const DonationAmountSelector({
    super.key,
    required this.onAmountChanged,
    this.selectedAmount,
  });

  @override
  State<DonationAmountSelector> createState() => _DonationAmountSelectorState();
}

class _DonationAmountSelectorState extends State<DonationAmountSelector> {
  final _customAmountController = TextEditingController();
  double? _selectedAmount;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.selectedAmount;
  }

  final List<double> _predefinedAmounts = [5, 10, 20, 50, 100, 200];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant de la donation',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Montants prédéfinis
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _predefinedAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAmount = amount;
                      _customAmountController.clear();
                    });
                    widget.onAmountChanged(amount);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${amount.toInt()}€',
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: 16),

        // Montant personnalisé
        TextField(
          controller: _customAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Montant personnalisé (€)',
            hintText: 'Entrez un montant',
            prefixIcon: const Icon(Icons.euro),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          onChanged: (value) {
            final amount = double.tryParse(value);
            if (amount != null && amount > 0) {
              setState(() {
                _selectedAmount = amount;
              });
              widget.onAmountChanged(amount);
            } else {
              setState(() {
                _selectedAmount = null;
              });
            }
          },
        ),

        const SizedBox(height: 8),

        Text(
          'Minimum: 1€ - Maximum: 10,000€',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }
}
