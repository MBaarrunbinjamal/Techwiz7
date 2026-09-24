import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFFFF3E0),
            child: Icon(Icons.cruelty_free, color: Colors.orange[800]),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PennyPal AI Guide",
              style: GoogleFonts.poppins(
                color: const Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Personalized student financial advice",
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.savings, color: Colors.brown),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "BudgetBee AI",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Active Coach",
                                  style: GoogleFonts.poppins(
                                    color: Colors.green[800],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Hi Alex! I'm your BudgetBee AI. Ask me anything about your budget, meal prep savings, or loan planning.",
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SUGGESTED PROMPTS",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "Explore prompts",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPromptChip("Can I afford dinner out tonight?", Icons.restaurant),
                    const SizedBox(width: 10),
                    _buildPromptChip("How do I cut down...", Icons.cut),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Today, 2:45 PM",
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C3E50),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "How much have I spent on coffee this month, and can I still hit my MacBook goal?",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("2:46 PM", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all, color: Colors.greenAccent, size: 14),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFFF3E0),
                    radius: 16,
                    child: Icon(Icons.cruelty_free, color: Colors.orange[800], size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(color: Colors.green[600]!, width: 4),
                          top: BorderSide(color: Colors.grey.shade200),
                          right: BorderSide(color: Colors.grey.shade200),
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.coffee, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "November Cafe Activity",
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                          children: const [
                                            TextSpan(text: "You've spent "),
                                            TextSpan(
                                              text: "\$42.50",
                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: " across 8 cafe visits this month (5.30/visit)."),
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
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, height: 1.5),
                              children: const [
                                TextSpan(text: "Good news! If you make coffee in your dorm 3 days a week, you'll save "),
                                TextSpan(text: "~\$35", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ", keeping your MacBook Air goal right on track for "),
                                TextSpan(text: "December 2024!", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.laptop_mac, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "M3 MacBook Air Fund  \$850 / \$1,050 (81%)",
                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.81,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.green[600],
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\$200 left to target",
                                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                    Text(
                                      "On track (18 days left)",
                                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.lock_outline, size: 16),
                            label: Text(
                              "Set \$30/mo Cafe Cap",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.visibility_outlined, size: 16),
                            label: Text("View Coffee History", style: GoogleFonts.poppins()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.grey[200],
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("Helpful", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                              const SizedBox(width: 12),
                              const Icon(Icons.thumb_down_alt_outlined, size: 14, color: Colors.grey),
                              const Spacer(),
                              Text("BudgetBee v2.4", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "BudgetBee is synced with your student checking account",
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Ask BudgetBee anything...",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.mic, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF00C853),
              radius: 24,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }
}