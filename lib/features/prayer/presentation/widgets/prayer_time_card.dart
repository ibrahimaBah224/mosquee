import 'package:flutter/material.dart';

class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final String time;
  final bool isNext;
  final bool isPassed;

  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.time,
    this.isNext = false,
    this.isPassed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isNext
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isNext ? 2 : 1,
        ),
        boxShadow: [
          if (isNext)
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Prayer Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNext ? Theme.of(context).primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.mosque,
              color: isNext ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Prayer Name & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                    color:
                        isNext
                            ? Theme.of(context).primaryColor
                            : isPassed
                            ? Colors.grey[600]
                            : Colors.black87,
                  ),
                ),
                if (isNext) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Prochaine prière',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Prayer Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isNext
                          ? Theme.of(context).primaryColor
                          : isPassed
                          ? Colors.grey[600]
                          : Colors.black87,
                ),
              ),
              if (isPassed) ...[
                const SizedBox(height: 2),
                Text(
                  'Terminé',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
