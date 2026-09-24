import 'package:flutter/material.dart';
import 'shared_app_bar.dart';

class UserManagementScreen extends StatefulWidget {
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  const UserManagementScreen({
    Key? key,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> students = [
    {
      'name': 'Alex Johnson',
      'email': 'alex.j@university.edu',
      'details': 'State University • Sophomore',
      'status': 'Active',
      'enrolled': 'Sep 2024',
      'activity': '142 txns',
      'balance': '\$1,420.00',
      'initials': 'AJ',
      'isActive': true,
      'isFlagged': false,
      'isPending': false,
    },
    {
      'name': 'Maya Lin',
      'email': 'm.lin@stanford.edu',
      'details': 'Stanford • Freshman',
      'status': 'Active',
      'enrolled': 'Oct 2024',
      'activity': '28 txns logged',
      'balance': '',
      'initials': 'ML',
      'isActive': true,
      'isFlagged': false,
      'isPending': false,
    },
    {
      'name': 'Marcus Vance',
      'email': 'mvance@nyu.edu',
      'details': 'NYU • Senior',
      'status': 'Deactivated',
      'enrolled': '',
      'activity': '',
      'balance': '',
      'initials': 'MV',
      'isActive': false,
      'isFlagged': true,
      'isPending': false,
    },
    {
      'name': 'Chloe Bennett',
      'email': 'c.bennett@columbia.edu',
      'details': 'Columbia University • ID Pending',
      'status': 'Pending Verification',
      'enrolled': '',
      'activity': '',
      'balance': '',
      'initials': 'CB',
      'isActive': false,
      'isFlagged': false,
      'isPending': true,
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredStudents {
    return students.where((s) {
      final matchesSearch = s['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          s['email'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          s['details'].toString().toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesFilter = true;
      if (selectedFilter == 'Active') matchesFilter = s['isActive'] == true;
      if (selectedFilter == 'Pending') matchesFilter = s['isPending'] == true;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: 'User Management',
        subtitle: '12,450 Students',
        showProfileIcon: true,
        onOpenNotifications: widget.onOpenNotifications,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildResultsHeader(),
            const SizedBox(height: 12),
            ...filteredStudents.map((s) => _buildUserCard(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (v) {
          setState(() {
            searchQuery = v;
          });
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search student, email, university...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('All Status', 'All', true),
          const SizedBox(width: 8),
          _buildChip('Active', 'Active', false, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _buildChip('Pending', 'Pending', false, const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, bool isFirst, [Color? bgColor, Color? textColor]) {
    final isActive = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1B5E20) : (bgColor ?? Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? const Color(0xFF1B5E20) : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : (textColor ?? Theme.of(context).textTheme.bodyLarge?.color),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Showing ${filteredStudents.length} results', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: const [
            Text('Sort by: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Recently Joined', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> student) {
    final isActive = student['isActive'] as bool;
    final isFlagged = student['isFlagged'] as bool;
    final isPending = student['isPending'] as bool;

    Color avatarBg = const Color(0xFFE8F5E9);
    Color avatarColor = const Color(0xFF2E7D32);
    if (isFlagged) {
      avatarBg = const Color(0xFFFFEBEE);
      avatarColor = const Color(0xFFC62828);
    } else if (isPending) {
      avatarBg = const Color(0xFFFFF3E0);
      avatarColor = const Color(0xFFEF6C00);
    } else if (student['name'] == 'Maya Lin') {
      avatarBg = const Color(0xFFE3F2FD);
      avatarColor = const Color(0xFF1565C0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarBg,
                    child: Text(student['initials'], style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold)),
                  ),
                  if (isActive)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).cardColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(student['name'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPending ? const Color(0xFFFFF3E0) : (isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student['status'],
                            style: TextStyle(
                              fontSize: 8,
                              color: isPending ? const Color(0xFFEF6C00) : (isActive ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(student['email'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Row(
                      children: [
                        const Icon(Icons.school, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(child: Text(student['details'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey))),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          if (isFlagged) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Color(0xFFC62828), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Flagged for multiple duplicate sync attempts across 3 mobile devices.',
                      style: TextStyle(fontSize: 10, color: Color(0xFFC62828)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Student ID Card Uploaded', style: TextStyle(fontSize: 10, color: Color(0xFF1565C0))),
                  Text('Inspect ID', style: TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          if (isActive && !isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enrolled', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(student['enrolled'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Activity', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(student['activity'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Balance', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(student['balance'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing ${student['name']}')),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      student['isActive'] = !isActive;
                      student['status'] = student['isActive'] ? 'Active' : 'Deactivated';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(student['isActive'] ? '${student['name']} activated' : '${student['name']} deactivated')),
                    );
                  },
                  icon: Icon(isActive ? Icons.block : Icons.check_circle, size: 16),
                  label: Text(isActive ? 'Deactivate' : 'Activate', style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isActive ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                    side: BorderSide(color: isActive ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}