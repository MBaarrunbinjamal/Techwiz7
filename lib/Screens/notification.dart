import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int navIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ink), onPressed: () => Navigator.pop(context)),
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
          ),
          IconButton(icon: const Icon(Icons.settings, color: AppColors.ink), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topSummary(),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All (4)', true),
                  const SizedBox(width: 8),
                  _chip('Alerts 2', false, badge: 2),
                  const SizedBox(width: 8),
                  _chip('Savings', false),
                  const SizedBox(width: 8),
                  _chip('Learning', false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _dayHeader('TODAY', '2 new'),
            const SizedBox(height: 10),
            _notifCard(
              icon: Icons.warning_amber_rounded,
              icoCol: AppColors.red,
              icoBg: AppColors.redSoft,
              title: 'Entertainment Budget Exceeded',
              sub: 'You\'ve spent \$140.00 of your \$120.00 limit for October. Tap to rebalance.',
              time: '2h ago',
              tag: '+16.6% over cap',
              tagCol: AppColors.red,
              greenDot: true,
              btn: 'Adjust Limits',
            ),
            const SizedBox(height: 12),
            _notifCard(
              icon: Icons.access_time,
              icoCol: AppColors.amber,
              icoBg: AppColors.amberSoft,
              title: 'Food & Dining reached 84%',
              sub: 'You have \$40.00 remaining for the next 7 days.',
              time: '4h ago',
              tag: 'Budget pace: Caution',
              tagCol: AppColors.amber,
              greenDot: true,
            ),
            const SizedBox(height: 20),
            _dayHeader('YESTERDAY', 'All caught up'),
            const SizedBox(height: 10),
            _notifCard(
              icon: Icons.emoji_events,
              icoCol: AppColors.green,
              icoBg: AppColors.greenSoft,
              title: 'Goal Milestone Reached! 🎉',
              sub: 'Your Emergency Semester Buffer reached 75% (\$600). Keep buzzing forward!',
              time: '1d ago',
              tag: 'Savings Hive',
              tagCol: AppColors.green,
              greenDot: false,
              pBar: 0.75,
            ),
            const SizedBox(height: 12),
            _notifCard(
              icon: Icons.menu_book,
              icoCol: AppColors.blue,
              icoBg: AppColors.blueSoft,
              title: 'New Tip: Grocery Meal Prep Hacks for Finals',
              sub: 'Read how students save \$60/wk during exam season.',
              time: '1d ago',
              tag: '3 min read',
              tagCol: AppColors.blue,
              greenDot: false,
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.fill, shape: BoxShape.circle),
                    child: const Icon(Icons.done_all, color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  const Text('You\'re up to date!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  const Text(
                    'No older notifications to show. We\'ll alert you whenever\nyour budget honey shifts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: const BorderSide(color: AppColors.track),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Clear notification history', style: TextStyle(color: AppColors.ink)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 0),
    );
  }

  Widget _topSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.amberSoft, shape: BoxShape.circle),
            child: const Icon(Icons.emoji_events, color: AppColors.amber),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget Health Check', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
                Text('2 alerts require action', style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(20)),
            child: const Text('Action needed', style: TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _dayHeader(String d, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(d, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
        Text(right, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }

  Widget _chip(String label, bool active, {int? badge}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.green : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.green : AppColors.track),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
              child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _notifCard({
    required IconData icon,
    required Color icoCol,
    required Color icoBg,
    required String title,
    required String sub,
    required String time,
    required String tag,
    required Color tagCol,
    required bool greenDot,
    String? btn,
    double? pBar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.track),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: icoBg, shape: BoxShape.circle),
                child: Icon(icon, color: icoCol, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink))),
                        if (greenDot)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(width: 8),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.muted, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(tag, style: TextStyle(color: tagCol, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          if (pBar != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pBar,
                backgroundColor: AppColors.track,
                color: AppColors.green,
                minHeight: 6,
              ),
            ),
          ],
          if (btn != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.greenSoft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(btn, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
              ),
            )
          ]
        ],
      ),
    );
  }
}
