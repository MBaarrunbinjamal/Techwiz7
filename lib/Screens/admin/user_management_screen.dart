import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'shared_app_bar.dart';
import 'user_detail_screen.dart';

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
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('users');

  String searchQuery = '';
  String selectedFilter = 'All';

  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final snapshot = await _dbRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        setState(() {
          _students = [];
          _isLoading = false;
        });
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final List<Map<String, dynamic>> loaded = [];

      data.forEach((userId, value) {
        if (value is! Map) return;
        final user = Map<String, dynamic>.from(value);

        final firstName = (user['FirstName'] ?? '').toString();
        final lastName = (user['LastName'] ?? '').toString();
        final fullName = '$firstName $lastName'.trim();
        final email = (user['Email'] ?? '').toString();
        final role = (user['Role'] ?? 'User').toString();

        // Status logic — Firebase me field ho to use karo, warna default
        final statusField = (user['status'] ?? user['Status'] ?? '').toString();
        final isActiveField = user['isActive'];

        bool isActive;
        bool isPending;
        bool isFlagged = false;

        if (statusField.isNotEmpty) {
          isActive = statusField.toLowerCase() == 'active';
          isPending = statusField.toLowerCase() == 'pending';
          isFlagged = statusField.toLowerCase() == 'flagged' ||
              statusField.toLowerCase() == 'deactivated';
        } else if (isActiveField is bool) {
          isActive = isActiveField;
          isPending = false;
        } else {
          // Default: agar kuch nahi hai to Active maan lo
          isActive = true;
          isPending = false;
        }

        final initials = _getInitials(fullName.isEmpty ? email : fullName);

        loaded.add({
          'userId': userId,
          'name': fullName.isEmpty ? 'Unknown' : fullName,
          'email': email,
          'details': role, // Role dikhayenge (purana university text hata diya)
          'status': statusField.isNotEmpty
              ? statusField
              : (isActive ? 'Active' : 'Deactivated'),
          'activity': '', // Firebase me abhi nahi hai
          'balance': '',  // Firebase me abhi nahi hai
          'initials': initials,
          'isActive': isActive,
          'isFlagged': isFlagged,
          'isPending': isPending,
          'role': role,
        });
      });

      // Sort by name
      loaded.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      setState(() {
        _students = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  List<Map<String, dynamic>> get filteredStudents {
    return _students.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      final role = (s['role'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase();

      final matchesSearch =
          name.contains(q) || email.contains(q) || role.contains(q);

      bool matchesFilter = true;
      if (selectedFilter == 'Active') matchesFilter = s['isActive'] == true;
      if (selectedFilter == 'Pending') matchesFilter = s['isPending'] == true;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _toggleUserStatus(Map<String, dynamic> student) async {
    final userId = student['userId'];
    final isActive = student['isActive'] as bool;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isActive ? 'Deactivate User?' : 'Activate User?'),
        content: Text(
            'Are you sure you want to ${isActive ? 'deactivate' : 'activate'} ${student['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Firebase me status update karo
      // NOTE: Agar team ne different field use ki hai, yahan adjust karo
      await _dbRef.child(userId).update({
        'isActive': !isActive,
        'status': isActive ? 'Deactivated' : 'Active',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${student['name']} ${isActive ? 'deactivated' : 'activated'}'),
          ),
        );
      }
      _loadUsers(); // refresh
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  void _openUserDetails(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(
          userId: student['userId'],
          userName: student['name'],
          userEmail: student['email'],
        ),
      ),
    ).then((_) => _loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: 'User Management',
        subtitle: '${_students.length} Students',
        showProfileIcon: true,
        onOpenNotifications: widget.onOpenNotifications,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RefreshIndicator(
        onRefresh: _loadUsers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              if (filteredStudents.isEmpty)
                _buildEmptyState()
              else
                ...filteredStudents.map((s) => _buildUserCard(s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error ?? 'Unknown error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('No users found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (v) {
          setState(() => searchQuery = v);
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search student, email, role...',
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
          _buildChip('Active', 'Active', false,
              const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          _buildChip('Pending', 'Pending', false,
              const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, bool isFirst,
      [Color? bgColor, Color? textColor]) {
    final isActive = selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1B5E20)
              : (bgColor ?? Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isActive
                  ? const Color(0xFF1B5E20)
                  : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Colors.white
                : (textColor ?? Theme.of(context).textTheme.bodyLarge?.color),
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
        Text('Showing ${filteredStudents.length} results',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: const [
            Text('Sort by: ',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Name',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarBg,
                    child: Text(student['initials'],
                        style: TextStyle(
                            color: avatarColor, fontWeight: FontWeight.bold)),
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
                          border: Border.all(
                              color: Theme.of(context).cardColor, width: 2),
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
                          child: Text(student['name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPending
                                ? const Color(0xFFFFF3E0)
                                : (isActive
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student['status'],
                            style: TextStyle(
                              fontSize: 8,
                              color: isPending
                                  ? const Color(0xFFEF6C00)
                                  : (isActive
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828)),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(student['email'],
                        style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(student['role'] ?? 'User',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ),
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
              decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Color(0xFFC62828), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'User account is deactivated or flagged.',
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
              decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Account Pending Verification',
                      style:
                      TextStyle(fontSize: 10, color: Color(0xFF1565C0))),
                  Text('Review',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openUserDetails(student),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleUserStatus(student),
                  icon: Icon(isActive ? Icons.block : Icons.check_circle,
                      size: 16),
                  label: Text(isActive ? 'Deactivate' : 'Activate',
                      style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isActive
                        ? const Color(0xFFC62828)
                        : const Color(0xFF2E7D32),
                    side: BorderSide(
                        color: isActive
                            ? const Color(0xFFFFCDD2)
                            : const Color(0xFFC8E6C9)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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