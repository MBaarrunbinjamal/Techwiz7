import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: const [
          Icon(Icons.receipt_long_outlined, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.green),
                    const SizedBox(width: 6),
                    Text("Active Term", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                      Text("This Semester (Fall 2024)", style: GoogleFonts.poppins(fontSize: 12)),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Total Inflow",
                    "\$4,200.00",
                    "Stipend & Campus Job",
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    "Total Outflow",
                    "\$2,750.00",
                    "65.4% of budget limit",
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
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
                          Text(
                            "Net Savings Rate",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.savings, color: Colors.green, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                "\$1,450.00",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                          Text("(34.5%)", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              "+5% vs last term",
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.345,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF00C853),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
                          Text(
                            "Weekly Spending Trend",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text("Weeks 1 - 8 Fall Expenditure", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                        child: Text("Avg: \$343/wk", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF2C3E50), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        "Peak: \$495 (W4)",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 600,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const style = TextStyle(color: Colors.grey, fontSize: 10);
                                Widget text;
                                switch (value.toInt()) {
                                  case 0: text = const Text('W1', style: style); break;
                                  case 1: text = const Text('W2', style: style); break;
                                  case 2: text = const Text('W3', style: style); break;
                                  case 3: text = const Text('W4', style: style); break;
                                  case 4: text = const Text('W5', style: style); break;
                                  case 5: text = const Text('W6', style: style); break;
                                  case 6: text = const Text('W7', style: style); break;
                                  case 7: text = const Text('W8', style: style); break;
                                  default: text = const Text('', style: style);
                                }
                                return SideTitleWidget(meta: meta, child: text);
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 300, Colors.green[100]!),
                          _buildBarGroup(1, 380, Colors.green[200]!),
                          _buildBarGroup(2, 250, Colors.green[100]!),
                          _buildBarGroup(3, 495, Colors.orange),
                          _buildBarGroup(4, 350, Colors.green[100]!),
                          _buildBarGroup(5, 280, Colors.green[100]!),
                          _buildBarGroup(6, 400, Colors.green[200]!),
                          _buildBarGroup(7, 230, const Color(0xFF00C853)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Textbooks & Move-in (Midterm peak)",
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                      ),
                      Text("Disciplined Week 8", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
                      Text(
                        "Category Breakdown",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                        child: Text("100% tracked", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  Text(
                    "Outflow allocation across 5 categories",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: [
                        Expanded(flex: 35, child: Container(height: 8, color: const Color(0xFF00C853))),
                        Expanded(flex: 25, child: Container(height: 8, color: const Color(0xFF536DFE))),
                        Expanded(flex: 20, child: Container(height: 8, color: Colors.orange)),
                        Expanded(flex: 12, child: Container(height: 8, color: const Color(0xFFFF5252))),
                        Expanded(flex: 8, child: Container(height: 8, color: Colors.cyan)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryRow("Food & Dining", "Groceries, dining hall, coffee", "\$962.50", "35%", const Color(0xFF00C853)),
                  const SizedBox(height: 12),
                  _buildCategoryRow("Education & Supplies", "Lab kits, books, prints", "\$687.50", "25%", const Color(0xFF536DFE)),
                  const SizedBox(height: 12),
                  _buildCategoryRow("Housing & Utilities", "Dorm share, Wi-Fi", "\$550.00", "20%", Colors.orange),
                  const SizedBox(height: 12),
                  _buildCategoryRow("Entertainment & Subs", "Streaming, cinema, gaming", "\$330.00", "12%", const Color(0xFFFF5252)),
                  const SizedBox(height: 12),
                  _buildCategoryRow("Transport", "Campus bus pass, rideshares", "\$220.00", "8%", Colors.cyan),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
                            Text(
                              "SMART INSIGHT",
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                "Oct Wins",
                                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, height: 1.4),
                            children: const [
                              TextSpan(text: "Your weekend grocery spending is "),
                              TextSpan(
                                text: "40% lower",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              TextSpan(text: " than dining out. You saved "),
                              TextSpan(text: "\$180.00", style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: " by meal planning in October!"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  "Download Complete CSV / PDF Report",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, String subtitle, Color color, IconData icon) {
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
              Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: color),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String title, String subtitle, String amount, String percent, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(percent, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ],
        )
      ],
    );
  }
}