import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationItem(
        icon: Icons.person_add,
        title: 'New student registered',
        subtitle: 'emily.r@berkeley.edu',
        time: '2m ago',
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
      ),
      _NotificationItem(
        icon: Icons.warning,
        title: 'Support ticket escalated',
        subtitle: 'Ticket #1042 assigned to High Priority',
        time: '15m ago',
        color: const Color(0xFFC62828),
        bg: const Color(0xFFFFEBEE),
      ),
      _NotificationItem(
        icon: Icons.edit_document,
        title: 'Lesson draft saved',
        subtitle: 'Tax 101 awaiting approval',
        time: '45m ago',
        color: const Color(0xFFEF6C00),
        bg: const Color(0xFFFFF3E0),
      ),
      _NotificationItem(
        icon: Icons.attach_money,
        title: 'Savings goal achieved',
        subtitle: 'Alex Johnson reached \$1500',
        time: '1h ago',
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
      ),
      _NotificationItem(
        icon: Icons.report,
        title: 'Duplicate sync detected',
        subtitle: 'Marcus Vance flagged',
        time: '3h ago',
        color: const Color(0xFFC62828),
        bg: const Color(0xFFFFEBEE),
      ),
      _NotificationItem(
        icon: Icons.school,
        title: 'New learning module published',
        subtitle: 'Credit Scores Decoded live',
        time: '5h ago',
        color: const Color(0xFF1565C0),
        bg: const Color(0xFFE3F2FD),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: n.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(n.icon, color: n.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(n.subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(n.time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final Color bg;

  _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.bg,
  });
}