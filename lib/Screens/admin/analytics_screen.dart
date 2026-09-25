import 'package:flutter/material.dart';
import 'shared_app_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  const AnalyticsScreen({
    Key? key,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: 'Analytics & Reports',
        subtitle: 'Real-time aggregate metrics',
        showProfileIcon: true,
        onOpenNotifications: onOpenNotifications,
        onOpenSettings: onOpenSettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterRow(context),
            const SizedBox(height: 16),
            _buildTelemetryCard(context),
            const SizedBox(height: 16),
            _buildCashflowCard(context),
            const SizedBox(height: 16),
            _buildSpendingCard(context),
            const SizedBox(height: 16),
            _buildHealthAlertsCard(context),
            const SizedBox(height: 16),
            _buildSavingsCard(context),
            const SizedBox(height: 16),
            _buildReportsCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Flexible(child: Text('This Semester (Fall 2024)', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(8)),
          child: const Text('Active Cohort', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User Activity Telemetry', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                child: const Text('Live', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryMetric('DAU', '8,920', '+8.4%', const Color(0xFF2E7D32)),
              _buildTelemetryMetric('Avg Session', '4m 12s', 'Normal', Colors.grey),
              _buildTelemetryMetric('Adoption', '78%', 'Daily Loggers', Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Weekly DAU Velocity', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            height: 80,
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                return Container(
                  width: 20,
                  height: 20.0 + (index * 8),
                  decoration: BoxDecoration(
                    color: index == 4 ? const Color(0xFF2E7D32) : const Color(0xFFC8E6C9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetric(String label, String value, String sub, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(sub, style: TextStyle(fontSize: 10, color: subColor)),
      ],
    );
  }

  Widget _buildCashflowCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance, size: 18, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Campus Cashflow Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Aggregated', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Student Inflow', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('\$840,500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    Text('Grants, jobs & allowance', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Student Outflow', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('\$512,300', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                    Text('Campus & living costs', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.trending_up, color: Color(0xFF2E7D32), size: 18),
                SizedBox(width: 8),
                Text('39.0%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Healthy Buffer: Average campus-wide net savings rate', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Category Spending Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('\$512.3K', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSpendingBar('Food & Dining', '\$184.4K', '36% of outflow', const Color(0xFF2E7D32)),
          _buildSpendingBar('Education & Books', '\$122.9K', '24% of outflow', const Color(0xFF1565C0)),
          _buildSpendingBar('Housing & Dorm', '\$92.2K', '18% of outflow', const Color(0xFF6A1B9A)),
          _buildSpendingBar('Entertainment & Social', '\$71.7K', '14% of outflow', const Color(0xFFEF6C00)),
          _buildSpendingBar('Transport', '\$41.1K', '8% of outflow', const Color(0xFFC62828)),
        ],
      ),
    );
  }

  Widget _buildSpendingBar(String label, String amount, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(percent, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAlertsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget Health & Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: Column(
                  children: [
                    Text('Budgets in Control', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('81%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    Text('10,084 students on track', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Alerts Triggered', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('1,420', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                    Text('Lead: Entertainment', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.warning, color: Color(0xFFC62828), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'High Alert Segment: First-year undergraduate cohorts accounted for 64% of overspending alerts during mid-term social weeks.',
                    style: TextStyle(fontSize: 10, color: Color(0xFFC62828)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Savings Milestones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
                child: const Text('Gamified', style: TextStyle(fontSize: 10, color: Color(0xFFEF6C00), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: Column(
                  children: [
                    Text('3,840', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Goals Completed', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('Fall semester milestone completions', style: TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('4.2 mos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Avg Completion', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('Speed increased by 14 days vs 2023', style: TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.emoji_events, color: Color(0xFFEF6C00), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Emergency Fund Badges: 2,110 students reached \$500 target',
                    style: TextStyle(fontSize: 10, color: Color(0xFF1B5E20)),
                  ),
                ),
                Text('+12.4%', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reports & Audit Exports', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                child: const Text('Instant Access', style: TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReportItem(Icons.description, 'Student Engagement Report', 'Comprehensive Fall 2024 (PDF 4.2 MB)'),
          _buildReportItem(Icons.table_chart, 'Campus Spending Trends', 'Raw anonymized transactions (CSV, 1.8 MB)'),
          _buildReportItem(Icons.shield, 'Compliance & Educational Log', 'Accreditation telemetry (PDF, 2.1 MB)'),
        ],
      ),
    );
  }

  Widget _buildReportItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18),
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
          const Icon(Icons.download, color: Color(0xFF2E7D32), size: 20),
        ],
      ),
    );
  }
}