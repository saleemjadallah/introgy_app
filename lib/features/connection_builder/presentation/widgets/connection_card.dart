import 'package:flutter/material.dart';

class ConnectionCard extends StatelessWidget {
  final String name;
  final String relationship;
  final DateTime lastContact;
  final String contactFrequency;
  final String priority;
  final String? image;
  final VoidCallback onTap;

  const ConnectionCard({
    super.key,
    required this.name,
    required this.relationship,
    required this.lastContact,
    required this.contactFrequency,
    required this.priority,
    this.image,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getLastContactText() {
    final days = DateTime.now().difference(lastContact).inDays;
    
    if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Yesterday';
    } else {
      return '$days days ago';
    }
  }

  bool _isDueForContact() {
    final days = DateTime.now().difference(lastContact).inDays;
    
    switch (contactFrequency) {
      case 'Daily':
        return days >= 1;
      case 'Weekly':
        return days >= 7;
      case 'Bi-weekly':
        return days >= 14;
      case 'Monthly':
        return days >= 30;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDue = _isDueForContact();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: image != null ? NetworkImage(image!) : null,
                child: image == null
                    ? Text(
                        name.substring(0, 1),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priority,
                            style: TextStyle(
                              color: _getPriorityColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      relationship,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: isDue ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Last contact: ${_getLastContactText()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDue ? Colors.red : Colors.grey.shade600,
                            fontWeight: isDue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isDue) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.notification_important,
                            size: 16,
                            color: Colors.red,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.repeat,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Contact frequency: $contactFrequency',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action button
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {
                  // TODO: Implement quick message action
                },
                tooltip: 'Quick message',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
