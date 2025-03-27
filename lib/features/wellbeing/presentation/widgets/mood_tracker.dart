import 'package:flutter/material.dart';

class MoodTracker extends StatefulWidget {
  const MoodTracker({super.key});

  @override
  State<MoodTracker> createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<MoodTracker> {
  int _selectedMoodIndex = -1;

  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😊',
      'label': 'Happy',
      'color': Colors.yellow.shade200,
    },
    {
      'emoji': '😌',
      'label': 'Calm',
      'color': Colors.blue.shade200,
    },
    {
      'emoji': '😐',
      'label': 'Neutral',
      'color': Colors.grey.shade200,
    },
    {
      'emoji': '😔',
      'label': 'Sad',
      'color': Colors.indigo.shade200,
    },
    {
      'emoji': '😫',
      'label': 'Overwhelmed',
      'color': Colors.purple.shade200,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _moods.asMap().entries.map((entry) {
            final index = entry.key;
            final mood = entry.value;
            final isSelected = index == _selectedMoodIndex;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMoodIndex = index;
                });
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? mood['color'] 
                          : mood['color'].withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      mood['emoji'],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mood['label'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        if (_selectedMoodIndex != -1) ...[
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add notes about why you\'re feeling ${_moods[_selectedMoodIndex]['label'].toLowerCase()}...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Save mood entry
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mood saved: ${_moods[_selectedMoodIndex]['label']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save Mood'),
          ),
        ],
      ],
    );
  }
}
