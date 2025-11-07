import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: isSmall
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        border: Border.all(
          color: statusConfig.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSmall) ...[
            Icon(
              statusConfig.icon,
              size: 14,
              color: statusConfig.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            statusConfig.text,
            style: TextStyle(
              color: statusConfig.color,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'bekliyor':
        return StatusConfig(
          text: 'Bekliyor',
          color: Colors.orange,
          icon: Icons.pending,
        );

      case 'processing':
      case 'baskida':
        return StatusConfig(
          text: 'Baskıda',
          color: Colors.blue,
          icon: Icons.print,
        );

      case 'ready':
      case 'hazir':
        return StatusConfig(
          text: 'Hazır',
          color: Colors.green,
          icon: Icons.check_circle,
        );

      case 'shipped':
      case 'kargoda':
        return StatusConfig(
          text: 'Kargoda',
          color: Colors.purple,
          icon: Icons.local_shipping,
        );

      case 'delivered':
      case 'teslim_edildi':
      case 'tamamlandi':
        return StatusConfig(
          text: 'Tamamlandı',
          color: Colors.green.shade700,
          icon: Icons.verified,
        );

      case 'cancelled':
      case 'iptal':
        return StatusConfig(
          text: 'İptal',
          color: Colors.red,
          icon: Icons.cancel,
        );

      case 'returned':
      case 'iade':
        return StatusConfig(
          text: 'İade',
          color: Colors.pink,
          icon: Icons.assignment_return,
        );

      default:
        return StatusConfig(
          text: status,
          color: Colors.grey,
          icon: Icons.help,
        );
    }
  }
}

class StatusConfig {
  final String text;
  final Color color;
  final IconData icon;

  StatusConfig({
    required this.text,
    required this.color,
    required this.icon,
  });
}

// Order Status Timeline Widget
class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;
  final List<String> statusHistory;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    this.statusHistory = const [],
  });

  @override
  Widget build(BuildContext context) {
    final allStatuses = [
      'bekliyor',
      'baskida',
      'hazir',
      'kargoda',
      'tamamlandi',
    ];

    final currentIndex = allStatuses.indexWhere(
            (status) => status == currentStatus.toLowerCase()
    );

    return Column(
      children: [
        // Timeline
        Row(
          children: allStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Expanded(
              child: Column(
                children: [
                  // Connection line
                  if (index > 0)
                    Container(
                      height: 2,
                      color: isCompleted ? Colors.green : Colors.grey.shade300,
                    ),

                  // Status dot
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: Colors.green, width: 3)
                          : null,
                    ),
                    child: isCompleted
                        ? Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Status labels
        Row(
          children: allStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentIndex;

            return Expanded(
              child: Text(
                _getStatusText(status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted ? Colors.green : Colors.grey.shade600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'bekliyor': return 'Bekliyor';
      case 'baskida': return 'Baskıda';
      case 'hazir': return 'Hazır';
      case 'kargoda': return 'Kargoda';
      case 'tamamlandi': return 'Tamamlandı';
      default: return status;
    }
  }
}