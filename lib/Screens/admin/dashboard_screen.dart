import 'package:flutter/material.dart';
import 'shared_app_bar.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  const DashboardScreen({
    Key? key,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: 'Admin Console',
        subtitle: 'Super Admin View',
        showProfileIcon: true,
        onOpenNotifications: onOpenNotifications,
        onOpenSettings: onOpenSettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopTabs(context),
            const SizedBox(height: 16),
            _buildStatusRow(),
            const SizedBox(height: 16),
            _buildMetricsGrid(context),
            const SizedBox(height: 16),
            _buildSavingsGoalsCard(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentActivity(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(context, 'Overview', true),
          _buildTabItem(context, 'Users', false),
          _buildTabItem(context, 'Content', false),
          _buildTabItem(context, 'Analytics', false),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).cardColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('Campus Network: Live Pulse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        const Text('Updated 1m ago', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(context, 'Total Students', '12,450', 'vs 11,070 last month', '+12.4%', const Color(0xFFE8F5E9), const Color(0xFF2E7D32))),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(context, 'Active Users', '8,920', 'Retention healthy', '71.6% DAU', const Color(0xFFFFF3E0), const Color(0xFFEF6C00))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(context, 'Txns Logged', '\$384.2K', '\$4,120 txns total', '+8.3%', const Color(0xFFE3F2FD), const Color(0xFF1565C0))),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(context, 'Support Queue', '14', 'Requires review', 'Needs Action', const Color(0xFFFFEBEE), const Color(0xFFC62828))),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, String subtitle, String badge, Color badgeBg, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.circle, size: 12, color: badgeColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                child: Text(badge, style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.emoji_events, color: Color(0xFFEF6C00), size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student Savings Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Aggregate student milestone tracking', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL TRACKED IN GOALS', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('\$1.24M', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                    Text('USD', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Active Pots', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('18,400', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Top Categories Breakdown', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('100% Allocated', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 42, child: Container(height: 8, decoration: const BoxDecoration(color: Color(0xFF2E7D32), borderRadius: BorderRadius.horizontal(left: Radius.circular(4))))),
              Expanded(flex: 35, child: Container(height: 8, color: const Color(0xFFF9A825))),
              Expanded(flex: 23, child: Container(height: 8, decoration: const BoxDecoration(color: Color(0xFF80CBC4), borderRadius: BorderRadius.horizontal(right: Radius.circular(4))))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryDot('Tuition', '42% (\$520K)', const Color(0xFF2E7D32)),
              _buildCategoryDot('Emergency', '35% (\$434K)', const Color(0xFFF9A825)),
              _buildCategoryDot('Tech & Gear', '23% (\$285K)', const Color(0xFF80CBC4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDot(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(value, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Quick Admin Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Configure', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, Icons.person_add, 'Manage Users', 'Search & access', const Color(0xFFE8F5E9), const Color(0xFF2E7D32))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, Icons.report, 'Review Queries', '14 Pending', const Color(0xFFFFEBEE), const Color(0xFFC62828))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, Icons.article, 'Publish Less...', 'Financial literacy', const Color(0xFFFFF3E0), const Color(0xFFEF6C00))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, Icons.download, 'Audit Log', 'CSV & SOC2 r...', const Color(0xFFE3F2FD), const Color(0xFF1565C0))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent System Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
              child: const Text('Audit', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityItem(context, Icons.person_add, 'New student registered', 'emily.r@berkeley.edu', '2m ago', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
        const SizedBox(height: 8),
        _buildActivityItem(context, Icons.warning, 'Support ticket #1042 escalated', 'Assigned by Mark T. to High Priority', '15m ago', const Color(0xFFFFEBEE), const Color(0xFFC62828)),
        const SizedBox(height: 8),
        _buildActivityItem(context, Icons.edit_document, 'Lesson draft saved: "Tax 101"', 'Author: Curriculum Team', '45m ago', const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, IconData icon, String title, String subtitle, String time, Color bgColor, Color iconColor) {
    return Container(
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
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}