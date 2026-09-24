import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.school, color: Colors.green),
        ),
        title: Text(
          "Financial Learning",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  "5 Day Streak",
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "NEXTGEN BUDGETBEE ACADEMY",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Level Up Your Student Wealth",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Daily Student Finance Tip",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text("Today", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          "Read in 3 min",
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue[800]),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.bookmark_border, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "The 50/30/20 Rule for College Students: How to balance tuition, fun, and emergency savings without burning out.",
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Learn practical proportions tailored specifically for flexible college gig paychecks and shared...",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Quick Read • 150XP", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                      Text(
                        "Read Tip →",
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800]),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Explore Topics", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Swipe to filter", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTopicChip("All", true),
                  _buildTopicChip("Budgeting Basics", false),
                  _buildTopicChip("Smart Saving", false),
                  _buildTopicChip("Credit", false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.monetization_on, color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "CHALLENGE OF THE WEEK",
                              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.brown, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                "+50 Honey Points!",
                                style: GoogleFonts.poppins(fontSize: 8, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Weekly Money Quiz", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          "Test your savvy on student credit cards",
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.brown[700]),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D4C41),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text("Play Quiz", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Featured Lessons", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  "View Curriculum",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLessonCard(
              tag: "Beginner",
              tagColor: Colors.blue[50]!,
              tagTextColor: Colors.blue[800]!,
              time: "4 min read",
              title: "Budgeting 101: Zero-Based Budgeting",
              subtitle: "Give every dollar a student job before the semester starts to eliminate month-end panic.",
              isCompleted: true,
              progress: 1.0,
            ),
            const SizedBox(height: 12),
            _buildLessonCard(
              tag: "Essential",
              tagColor: const Color(0xFFFFEBEE),
              tagTextColor: Colors.red[800]!,
              time: "3 min read",
              title: "Needs vs Wants: The Impulse Spending Checklist",
              subtitle: "Master the 24-hour rule before making campus coffee runs and online checkout splurges.",
              isCompleted: false,
              isRecommended: true,
              buttonText: "Start Lesson →",
              honeyPoints: "+25 Honey Points",
            ),
            const SizedBox(height: 12),
            _buildLessonCard(
              tag: "Savings",
              tagColor: Colors.green[50]!,
              tagTextColor: Colors.green[800]!,
              time: "5 min read",
              title: "Building an Emergency Fund on a Student Income",
              subtitle: "How micro-deposits of \$5 to \$15 weekly can protect your education from sudden textbook or car repair fees.",
              isCompleted: false,
              moduleInfo: "Module 3 of 6",
            ),
            const SizedBox(height: 12),
            _buildLessonCard(
              tag: "Intermediate",
              tagColor: Colors.purple[50]!,
              tagTextColor: Colors.purple[800]!,
              time: "6 min read",
              title: "Understanding Credit Scores Before You Graduate",
              subtitle: "",
              isCompleted: false,
              isBookmarked: true,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E20) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard({
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String time,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isRecommended = false,
    bool isBookmarked = false,
    double progress = 0.0,
    String? buttonText,
    String? honeyPoints,
    String? moduleInfo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  tag,
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: tagTextColor),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(time, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              const Spacer(),
              if (isCompleted)
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      "Done",
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Text("Recommended", style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue[800])),
                ),
              if (isBookmarked) const Icon(Icons.bookmark, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.4)),
          ],
          if (isCompleted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text("Completed", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                const Spacer(),
                Text("100%", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF00C853),
                minHeight: 6,
              ),
            ),
          ],
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (honeyPoints != null)
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        honeyPoints,
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                else if (moduleInfo != null)
                  Text(moduleInfo, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                if (buttonText != null)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  )
                else if (moduleInfo != null)
                  Text(
                    "Open →",
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  ),
              ],
            )
          ]
        ],
      ),
    );
  }
}