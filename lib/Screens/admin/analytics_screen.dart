import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'shared_app_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  final VoidCallback onOpenSettings;

  const AnalyticsScreen({
    Key? key,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  bool _isLoading = true;
  int _totalStudents = 0;
  int _activeUsers = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  int _totalIncomeEntries = 0;
  int _totalExpenseEntries = 0;
  int _totalGoals = 0;
  int _totalBudgets = 0;
  int _totalFeedback = 0;
  int _totalSupport = 0;
  int _totalLearning = 0;

  Map<String, double> _expenseByCategory = {};
  Map<String, double> _incomeBySource = {};

  List<Map<String, dynamic>> _goalsList = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final usersSnap = await _db.child('users').get();
      int activeCount = 0;
      int totalCount = 0;
      if (usersSnap.exists && usersSnap.value is Map) {
        final users = Map<String, dynamic>.from(usersSnap.value as Map);
        totalCount = users.length;
        users.forEach((_, v) {
          if (v is Map) {
            final u = Map<String, dynamic>.from(v);
            final isActive = u['isActive'];
            final status = (u['status'] ?? '').toString().toLowerCase();
            if (isActive == true ||
                status == 'active' ||
                (isActive == null && status.isEmpty)) {
              activeCount++;
            }
          }
        });
      }

      double income = 0;
      int incomeCount = 0;
      final incomeMap = <String, double>{};
      try {
        final snap = await _db.child('income').get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          final list = <Map<String, dynamic>>[];
          if (raw is List) {
            for (final v in raw) {
              if (v is Map) list.add(Map<String, dynamic>.from(v));
            }
          } else if (raw is Map) {
            final d = Map<String, dynamic>.from(raw);
            d.forEach((_, v) {
              if (v is Map) list.add(Map<String, dynamic>.from(v));
            });
          }
          for (final item in list) {
            final amt = _parse(item['amount']);
            income += amt;
            incomeCount++;
            final src = (item['source'] ?? 'Other').toString();
            incomeMap[src] = (incomeMap[src] ?? 0) + amt;
          }
        }
      } catch (_) {}

      double expense = 0;
      int expenseCount = 0;
      final expenseMap = <String, double>{};
      try {
        final snap = await _db.child('expense').get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          final list = <Map<String, dynamic>>[];
          if (raw is List) {
            for (final v in raw) {
              if (v is Map) list.add(Map<String, dynamic>.from(v));
            }
          } else if (raw is Map) {
            final d = Map<String, dynamic>.from(raw);
            d.forEach((_, v) {
              if (v is Map) list.add(Map<String, dynamic>.from(v));
            });
          }
          for (final item in list) {
            final amt = _parse(item['amount']);
            expense += amt;
            expenseCount++;
            final cat = (item['source'] ??
                item['category'] ??
                'Miscellaneous')
                .toString();
            expenseMap[cat] = (expenseMap[cat] ?? 0) + amt;
          }
        }
      } catch (_) {}

      int goalsCount = 0;
      final goalsList = <Map<String, dynamic>>[];
      try {
        final snap = await _db.child('goals').get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          final list = <Map<String, dynamic>>[];
          if (raw is List) {
            for (final v in raw) {
              if (v is Map) list.add(Map<String, dynamic>.from(v));
            }
          } else if (raw is Map) {
            final d = Map<String, dynamic>.from(raw);
            d.forEach((k, v) {
              if (v is Map) {
                final m = Map<String, dynamic>.from(v);
                m['_key'] = k;
                list.add(m);
              }
            });
          }
          goalsCount = list.length;
          goalsList.addAll(list);
        }
      } catch (_) {}

      int budgetsCount = 0;
      try {
        final snap = await _db.child('budgets').get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          if (raw is List) {
            budgetsCount = raw.length;
          } else if (raw is Map) {
            budgetsCount = (raw as Map).length;
          }
        }
      } catch (_) {}

      int feedbackCount = 0;
      try {
        final snap = await _db.child('feedback').get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          if (raw is List) {
            feedbackCount = raw.length;
          } else if (raw is Map) {
            feedbackCount = (raw as Map).length;
          }
        }
      } catch (_) {}

      int supportCount = 0;
      try {
        final snap = await _db.child('support').get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          if (raw is List) {
            supportCount = raw.length;
          } else if (raw is Map) {
            supportCount = (raw as Map).length;
          }
        }
      } catch (_) {}

      int learningCount = 0;
      try {
        final snap = await _db.child('learning').get();
        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          if (raw is List) {
            learningCount = raw.length;
          } else if (raw is Map) {
            learningCount = (raw as Map).length;
          }
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _totalStudents = totalCount;
        _activeUsers = activeCount;
        _totalIncome = income;
        _totalExpense = expense;
        _totalIncomeEntries = incomeCount;
        _totalExpenseEntries = expenseCount;
        _totalGoals = goalsCount;
        _totalBudgets = budgetsCount;
        _totalFeedback = feedbackCount;
        _totalSupport = supportCount;
        _totalLearning = learningCount;
        _expenseByCategory = expenseMap;
        _incomeBySource = incomeMap;
        _goalsList = goalsList;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _parse(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _money(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: 'Analytics & Reports',
        subtitle: 'Real-time aggregate metrics',
        showProfileIcon: true,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTelemetryCard(context),
              const SizedBox(height: 16),
              _buildCashflowCard(context),
              const SizedBox(height: 16),
              _buildSpendingCard(context),
              const SizedBox(height: 16),
              _buildGoalsCard(context),
              const SizedBox(height: 16),
              _buildPlatformStatsCard(context),
              const SizedBox(height: 16),
              _buildReportsCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User Activity',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric('Students', '$_totalStudents', 'registered'),
              _metric('Active', '$_activeUsers', 'live'),
              _metric(
                  'Adoption',
                  '${_totalStudents > 0 ? ((_activeUsers / _totalStudents) * 100).toStringAsFixed(0) : 0}%',
                  'of total'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCashflowCard(BuildContext context) {
    final net = _totalIncome - _totalExpense;
    final ratio = _totalIncome > 0 ? (net / _totalIncome * 100) : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance,
                    size: 18, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform Cashflow',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Aggregated',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                  children: [
                    const Text('Student Inflow',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(_money(_totalIncome),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                    Text('$_totalIncomeEntries entries',
                        style:
                        const TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student Outflow',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(_money(_totalExpense),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828))),
                    Text('$_totalExpenseEntries entries',
                        style:
                        const TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.trending_up,
                    color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 8),
                Text('${ratio.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32))),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Net savings rate across all users',
                      style:
                      TextStyle(fontSize: 10, color: Color(0xFF2E7D32))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingCard(BuildContext context) {
    final sorted = _expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = _totalExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Category Spending',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(_money(_totalExpense),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No expense data yet',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            )
          else
            ...sorted.take(8).map((e) {
              final pct = total > 0 ? (e.value / total * 100) : 0;
              return _bar(e.key, _money(e.value),
                  '${pct.toStringAsFixed(0)}% of outflow', _color(e.key));
            }),
        ],
      ),
    );
  }

  Color _color(String key) {
    const colors = [
      Color(0xFF2E7D32),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFFEF6C00),
      Color(0xFFC62828),
      Color(0xFF00838F),
      Color(0xFF5D4037),
      Color(0xFF455A64),
    ];
    return colors[key.hashCode.abs() % colors.length];
  }

  Widget _bar(String label, String amount, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold))),
              Text(amount,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(percent,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context) {
    int active = 0;
    int completed = 0;
    double totalSaved = 0;
    double totalTarget = 0;
    for (final g in _goalsList) {
      final saved = _parse(g['saved']);
      final target = _parse(g['target']);
      final status = (g['status'] ?? 'active').toString().toLowerCase();
      totalSaved += saved;
      totalTarget += target;
      if (status == 'completed' || (target > 0 && saved >= target)) {
        completed++;
      } else {
        active++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Savings Goals',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('Gamified',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFEF6C00),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('$_totalGoals',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Total Goals',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('$active',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0))),
                    const Text('Active',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('$completed',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                    const Text('Completed',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.emoji_events,
                    color: Color(0xFFEF6C00), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total saved: ${_money(totalSaved)} of ${_money(totalTarget)} target',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF1B5E20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Activity',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _miniStat('Budgets', '$_totalBudgets',
                      Icons.pie_chart, const Color(0xFF3B5BFF))),
              const SizedBox(width: 8),
              Expanded(
                  child: _miniStat('Feedback', '$_totalFeedback',
                      Icons.feedback, const Color(0xFFEF6C00))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _miniStat('Support', '$_totalSupport',
                      Icons.support_agent, const Color(0xFFC62828))),
              const SizedBox(width: 8),
              Expanded(
                  child: _miniStat('Learning', '$_totalLearning',
                      Icons.menu_book, const Color(0xFF2E7D32))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reports & Exports',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('Auto',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _reportRow(Icons.description, 'User Engagement Report',
              '$_totalStudents users • $_totalTransactionsLabel()'),
          _reportRow(Icons.table_chart, 'Transaction Summary',
              '$_totalIncomeEntries income • $_totalExpenseEntries expense'),
          _reportRow(Icons.emoji_events, 'Goals Progress',
              '$_totalGoals goals tracked'),
        ],
      ),
    );
  }

  String _totalTransactionsLabel() {
    return '${_totalIncomeEntries + _totalExpenseEntries} txns';
  }

  Widget _reportRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18),
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
          const Icon(Icons.download, color: Color(0xFF2E7D32), size: 20),
        ],
      ),
    );
  }

  BoxDecoration _card(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
    );
  }
}