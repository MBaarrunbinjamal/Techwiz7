import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'shared_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  const DashboardScreen({
    Key? key,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  int _totalStudents = 0;
  int _activeUsers = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  int _totalTransactions = 0;

  List<Map<String, dynamic>> _recentUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      // Users
      final usersSnap = await _db.child('users').get();
      int activeCount = 0;
      int totalCount = 0;
      final List<Map<String, dynamic>> usersList = [];

      if (usersSnap.exists && usersSnap.value is Map) {
        final users = Map<String, dynamic>.from(usersSnap.value as Map);
        totalCount = users.length;

        users.forEach((uid, value) {
          if (value is Map) {
            final u = Map<String, dynamic>.from(value);
            final isActive = u['isActive'];
            final status = (u['status'] ?? u['Status'] ?? '').toString().toLowerCase();
            if (isActive == true ||
                status == 'active' ||
                (isActive == null && status.isEmpty)) {
              activeCount++;
            }
            usersList.add({...u, 'userId': uid});
          }
        });
      }

      // Income
      double income = 0;
      int incomeCount = 0;
      try {
        final incomeSnap = await _db.child('income').get();
        if (incomeSnap.exists && incomeSnap.value is Map) {
          final data = Map<String, dynamic>.from(incomeSnap.value as Map);
          data.forEach((_, v) {
            if (v is Map) {
              income += _parseAmount(v['amount']);
              incomeCount++;
            }
          });
        }
      } catch (_) {}

      // Expense
      double expense = 0;
      int expenseCount = 0;
      try {
        final expenseSnap = await _db.child('expense').get();
        if (expenseSnap.exists && expenseSnap.value is Map) {
          final data = Map<String, dynamic>.from(expenseSnap.value as Map);
          data.forEach((_, v) {
            if (v is Map) {
              expense += _parseAmount(v['amount']);
              expenseCount++;
            }
          });
        }
      } catch (_) {}

      setState(() {
        _totalStudents = totalCount;
        _activeUsers = activeCount;
        _totalIncome = income;
        _totalExpense = expense;
        _totalTransactions = incomeCount + expenseCount;
        _recentUsers = usersList.reversed.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _formatMoney(double v) {
    if (v >= 1000000) return 'Rs ${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return 'Rs ${(v / 1000).toStringAsFixed(1)}K';
    return 'Rs ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: 'Admin Console',
        subtitle: 'Super Admin View',
        showProfileIcon: true,
        onOpenNotifications: widget.onOpenNotifications,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildTopTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
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
          color: isActive
              ? Theme.of(context).textTheme.bodyLarge?.color
              : Colors.grey,
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
              decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('Firebase: Live',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        const Text('Real-time',
            style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Column(
      children: [
        // Row 1: Total Students + Active Users
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Students',
                '$_totalStudents',
                'Registered users',
                'Live',
                const Color(0xFFE8F5E9),
                const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Active Users',
                '$_activeUsers',
                '${_totalStudents > 0 ? ((_activeUsers / _totalStudents) * 100).toStringAsFixed(0) : 0}% of total',
                'Active',
                const Color(0xFFFFF3E0),
                const Color(0xFFEF6C00),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Total Income + Total Expense  ← NEW
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Income',
                _formatMoney(_totalIncome),
                'All users combined',
                '+ Income',
                const Color(0xFFE8F5E9),
                const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Expense',
                _formatMoney(_totalExpense),
                'All users combined',
                '- Expense',
                const Color(0xFFFFEBEE),
                const Color(0xFFC62828),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Txns + Balance
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Txns Logged',
                '$_totalTransactions',
                'Income + Expense',
                'Total',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Net Balance',
                _formatMoney(_totalIncome - _totalExpense),
                'Income - Expense',
                _totalIncome - _totalExpense >= 0 ? 'Healthy' : 'Negative',
                const Color(0xFFF1F8E9),
                const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      String subtitle, String badge, Color badgeBg, Color badgeColor) {
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: badgeBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.circle, size: 12, color: badgeColor),
              ),
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: badgeBg, borderRadius: BorderRadius.circular(12)),
                  child: Text(badge,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          color: badgeColor,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.emoji_events,
                    color: Color(0xFFEF6C00), size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Overview',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Total income vs expense across users',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL INCOME',
                        style:
                        TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(_formatMoney(_totalIncome),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20))),
                    const Text('PKR',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Expense',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(_formatMoney(_totalExpense),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Balance Breakdown',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Live',
                  style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  flex: _totalIncome + _totalExpense > 0
                      ? ((_totalIncome / (_totalIncome + _totalExpense)) * 100)
                      .toInt()
                      .clamp(1, 99)
                      : 50,
                  child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(4))))),
              Expanded(
                  flex: _totalIncome + _totalExpense > 0
                      ? ((_totalExpense / (_totalIncome + _totalExpense)) * 100)
                      .toInt()
                      .clamp(1, 99)
                      : 50,
                  child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFFC62828),
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(4))))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryDot('Income', _formatMoney(_totalIncome),
                  const Color(0xFF2E7D32)),
              _buildCategoryDot('Expense', _formatMoney(_totalExpense),
                  const Color(0xFFC62828)),
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
            Container(
                width: 8,
                height: 8,
                decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(title,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(value,
              style: const TextStyle(fontSize: 9, color: Colors.grey)),
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
            Text('Quick Admin Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Configure',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildActionCard(context, Icons.person_add,
                    'Manage Users', '$_totalStudents registered',
                    const Color(0xFFE8F5E9), const Color(0xFF2E7D32))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildActionCard(context, Icons.report,
                    'Review Queries', 'Support',
                    const Color(0xFFFFEBEE), const Color(0xFFC62828))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildActionCard(context, Icons.article,
                    'Publish Less...', 'Financial literacy',
                    const Color(0xFFFFF3E0), const Color(0xFFEF6C00))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildActionCard(context, Icons.download,
                    'Audit Log', 'Export',
                    const Color(0xFFE3F2FD), const Color(0xFF1565C0))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title,
      String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
            const Text('Recently Registered Users',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('Live',
                  style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentUsers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No users yet',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          )
        else
          ..._recentUsers.map((u) {
            final first = (u['FirstName'] ?? '').toString();
            final last = (u['LastName'] ?? '').toString();
            final email = (u['Email'] ?? '').toString();
            final role = (u['Role'] ?? 'User').toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildActivityItem(
                context,
                Icons.person,
                '$first $last'.trim().isEmpty ? 'Unknown User' : '$first $last',
                '$email • $role',
                'New',
                const Color(0xFFE8F5E9),
                const Color(0xFF2E7D32),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, IconData icon, String title,
      String subtitle, String time, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text(time,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}