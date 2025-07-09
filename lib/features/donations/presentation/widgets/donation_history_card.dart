import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DonationHistoryCard extends StatelessWidget {
  final String category;
  final double amount;
  final DateTime date;
  final String status;
  final String? reference;

  const DonationHistoryCard({
    super.key,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
    this.reference,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'terminé':
        return Colors.green;
      case 'pending':
      case 'en attente':
        return Colors.orange;
      case 'failed':
      case 'échoué':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get _categoryIcon {
    switch (category.toLowerCase()) {
      case 'zakat':
        return Icons.mosque;
      case 'sadaqah':
        return Icons.favorite;
      case 'mosquée':
        return Icons.architecture;
      case 'éducation':
        return Icons.school;
      case 'orphelins':
        return Icons.child_care;
      case 'urgence':
        return Icons.emergency;
      default:
        return Icons.volunteer_activism;
    }
  }

  String get _statusText {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormatter.format(date)} à ${timeFormatter.format(date)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    if (reference != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Réf: $reference',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Amount and Actions
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_money,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormat.currency(
                          locale: 'fr_FR',
                          symbol: 'GNF',
                          decimalDigits: 0,
                        ).format(amount),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Action Button
              if (status.toLowerCase() == 'completed')
                IconButton(
                  onPressed: () {
                    // TODO: Show receipt or details
                  },
                  icon: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: 'Voir le reçu',
                )
              else if (status.toLowerCase() == 'pending')
                IconButton(
                  onPressed: () {
                    // TODO: Check status or cancel
                  },
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  tooltip: 'Vérifier le statut',
                )
              else
                IconButton(
                  onPressed: () {
                    // TODO: Retry donation
                  },
                  icon: const Icon(Icons.replay, color: Colors.red),
                  tooltip: 'Réessayer',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
