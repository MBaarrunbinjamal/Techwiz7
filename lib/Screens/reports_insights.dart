import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  bool _isLoading = true;
  double _totalIncome = 0;
  double _totalExpense = 0;
  int _incomeCount = 0;
  int _expenseCount = 0;

  Map<String, double> _expenseByCategory = {};
  Map<String, double> _incomeBySource = {};
  List<Map<String, dynamic>> _weeklyExpense = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final incomeList = <Map<String, dynamic>>[];
      final incomeSnap = await _db.child('income').get();
      if (incomeSnap.exists && incomeSnap.value != null) {
        final raw = incomeSnap.value;
        if (raw is List) {
          for (final v in raw) {
            if (v is Map) incomeList.add(Map<String, dynamic>.from(v));
          }
        } else if (raw is Map) {
          final d = Map<String, dynamic>.from(raw);
          d.forEach((_, v) {
            if (v is Map) incomeList.add(Map<String, dynamic>.from(v));
          });
        }
      }

      final expenseList = <Map<String, dynamic>>[];
      final expenseSnap = await _db.child('expense').get();
      if (expenseSnap.exists && expenseSnap.value != null) {
        final raw = expenseSnap.value;
        if (raw is List) {
          for (final v in raw) {
            if (v is Map) expenseList.add(Map<String, dynamic>.from(v));
          }
        } else if (raw is Map) {
          final d = Map<String, dynamic>.from(raw);
          d.forEach((_, v) {
            if (v is Map) expenseList.add(Map<String, dynamic>.from(v));
          });
        }
      }

      double totalInc = 0;
      int incCount = 0;
      final incMap = <String, double>{};
      for (final item in incomeList) {
        if ((item['userid'] ?? item['userId']) == uid) {
          final amt = _parse(item['amount']);
          totalInc += amt;
          incCount++;
          final src = (item['source'] ?? 'Other').toString();
          incMap[src] = (incMap[src] ?? 0) + amt;
        }
      }

      double totalExp = 0;
      int expCount = 0;
      final expMap = <String, double>{};
      final weekly = <Map<String, dynamic>>[];
      final now = DateTime.now();
      final eightWeeksAgo = now.subtract(const Duration(days: 56));

      for (final item in expenseList) {
        if ((item['userid'] ?? item['userId']) == uid) {
          final amt = _parse(item['amount']);
          totalExp += amt;
          expCount++;
          final cat =
          (item['source'] ?? item['category'] ?? 'Miscellaneous')
              .toString();
          expMap[cat] = (expMap[cat] ?? 0) + amt;

          try {
            final dateStr = (item['date'] ?? '').toString();
            final dt = DateTime.parse(dateStr);
            if (dt.isAfter(eightWeeksAgo)) {
              final weekNum = ((now.difference(dt).inDays) / 7).floor();
              weekly.add({'week': weekNum, 'amount': amt});
            }
          } catch (_) {}
        }
      }

      final weeklyBuckets = <int, double>{};
      for (final w in weekly) {
        final wk = w['week'] as int;
        weeklyBuckets[wk] = (weeklyBuckets[wk] ?? 0) + (w['amount'] as double);
      }

      final weeklyList = <Map<String, dynamic>>[];
      for (int i = 7; i >= 0; i--) {
        weeklyList.add({
          'week': 8 - i,
          'amount': weeklyBuckets[i] ?? 0,
        });
      }

      if (!mounted) return;
      setState(() {
        _totalIncome = totalInc;
        _totalExpense = totalExp;
        _incomeCount = incCount;
        _expenseCount = expCount;
        _expenseByCategory = expMap;
        _incomeBySource = incMap;
        _weeklyExpense = weeklyList;
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
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(2)}K';
    return '\$${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final net = _totalIncome - _totalExpense;
    final savingsRate = _totalIncome > 0 ? (net / _totalIncome) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.pie_chart_outline, color: Colors.green),
        ),
        title: Text(
          "Reports & Insights",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/notification'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPeriodRow(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      "Total Inflow",
                      _money(_totalIncome),
                      '$_incomeCount entries',
                      Colors.green,
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      "Total Outflow",
                      _money(_totalExpense),
                      '$_expenseCount entries',
                      Colors.red,
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSavingsRateCard(net, savingsRate),
              const SizedBox(height: 16),
              _buildWeeklyChart(),
              const SizedBox(height: 16),
              _buildCategoryCard(),
              const SizedBox(height: 16),
              _buildIncomeCard(),
              const SizedBox(height: 16),
              _buildInsightCard(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                          Text('Report export coming soon')),
                    );
                  },
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: Text(
                    "Download Complete CSV / PDF Report",
                    style:
                    GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PennyBottomNav(currentIndex: 4),
    );
  }

  Widget _buildPeriodRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.green),
            const SizedBox(width: 6),
            Text("Active",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.green),
              const SizedBox(width: 8),
              Text("All Time",
                  style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title, String amount, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style:
                  GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount,
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSavingsRateCard(double net, double rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Net Savings Rate",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.savings,
                          color: Colors.green, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        _money(net),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  Text("(${(rate * 100).toStringAsFixed(1)}%)",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: net >= 0
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                        net >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: net >= 0 ? Colors.green : Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      net >= 0 ? 'Positive' : 'Negative',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: net >= 0
                              ? Colors.green[800]
                              : Colors.red[800],
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF00C853),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    double maxY = 0;
    for (final w in _weeklyExpense) {
      final amt = (w['amount'] as double);
      if (amt > maxY) maxY = amt;
    }
    if (maxY == 0) maxY = 100;
    maxY = maxY * 1.2;

    double avg = 0;
    if (_weeklyExpense.isNotEmpty) {
      double sum = 0;
      for (final w in _weeklyExpense) {
        sum += (w['amount'] as double);
      }
      avg = sum / _weeklyExpense.length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Weekly Spending Trend",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Last 8 weeks",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("Avg: ${_money(avg)}/wk",
                    style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text('W${value.toInt() + 1}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _weeklyExpense.asMap().entries.map((e) {
                  final amt = e.value['amount'] as double;
                  final isMax = amt == maxY / 1.2 && amt > 0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: amt,
                        color: isMax
                            ? Colors.orange
                            : const Color(0xFFC8E6C9),
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    final sorted = _expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = _totalExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Category Breakdown",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("${sorted.length} categories",
                    style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text("Outflow allocation",
              style:
              GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No expense data yet',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: sorted.take(5).map((e) {
                  final flex = total > 0
                      ? ((e.value / total) * 100).round().clamp(1, 100)
                      : 20;
                  return Expanded(
                    flex: flex,
                    child: Container(
                        height: 8, color: _colorFor(e.key)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ...sorted.take(6).map((e) {
              final pct = total > 0 ? (e.value / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _categoryRow(
                  e.key,
                  _money(e.value),
                  '${pct.toStringAsFixed(0)}%',
                  _colorFor(e.key),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _colorFor(String key) {
    const colors = [
      Color(0xFF00C853),
      Color(0xFF536DFE),
      Colors.orange,
      Color(0xFFFF5252),
      Colors.cyan,
      Color(0xFF6A1B9A),
      Color(0xFF5D4037),
      Color(0xFF455A64),
    ];
    return colors[key.hashCode.abs() % colors.length];
  }

  Widget _categoryRow(
      String title, String amount, String percent, Color color) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount,
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            Text(percent,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeCard() {
    final sorted = _incomeBySource.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Income Sources",
              style:
              GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Where your money comes from",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No income data yet',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            )
          else
            ...sorted.take(6).map((e) {
              final pct =
              _totalIncome > 0 ? (e.value / _totalIncome * 100) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.arrow_downward,
                          color: Color(0xFF2E7D32), size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.key,
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_money(e.value),
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('${pct.toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    final topExpense = _expenseByCategory.entries.isEmpty
        ? null
        : _expenseByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    String insight =
        'Add more transactions to unlock personalized smart insights.';
    if (topExpense != null) {
      insight =
      'Your biggest spending category is "${topExpense.key}" at ${_money(topExpense.value)}. Consider setting a budget cap for it.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("SMART INSIGHT",
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800])),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("Auto",
                          style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800])),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(insight,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.black87, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}