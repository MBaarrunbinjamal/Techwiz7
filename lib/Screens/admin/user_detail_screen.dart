import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'shared_app_bar.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const UserDetailScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _income = [];
  bool _isLoading = true;
  String? _error;

  double _totalIncome = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _income.clear();
      _totalIncome = 0;
    });

    try {
      // 1. User profile
      final profileSnap = await _db.child('users/${widget.userId}').get();
      if (profileSnap.exists && profileSnap.value is Map) {
        _userProfile = Map<String, dynamic>.from(profileSnap.value as Map);
      }

      // 2. Income — root pe hai, userid filter karo
      final incomeSnap = await _db.child('income').get();
      if (incomeSnap.exists && incomeSnap.value is Map) {
        final data = Map<String, dynamic>.from(incomeSnap.value as Map);
        data.forEach((key, value) {
          if (value is Map) {
            final item = Map<String, dynamic>.from(value);
            if (item['userid'] == widget.userId) {
              item['_key'] = key;
              _income.add(item);
              _totalIncome += _parseAmount(item['amount']);
            }
          }
        });
      }

      // Sort by date — latest first
      _income.sort((a, b) {
        final da = (a['date'] ?? '').toString();
        final db = (b['date'] ?? '').toString();
        return db.compareTo(da);
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _isLoading = false;
      });
    }
  }

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: widget.userName,
        subtitle: widget.userEmail,
        showProfileIcon: false,
        onOpenNotifications: () {},
        onOpenSettings: () {},
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildSectionHeader('Income History', _income.length),
              const SizedBox(height: 8),
              if (_income.isEmpty)
                _buildEmpty('No income records')
              else
                ..._income.map((e) => _buildIncomeTile(e)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final p = _userProfile ?? {};
    final firstName = (p['FirstName'] ?? '').toString();
    final lastName = (p['LastName'] ?? '').toString();
    final email = (p['Email'] ?? widget.userEmail).toString();
    final role = (p['Role'] ?? 'User').toString();
    final isActive = p['isActive'];
    final status = (p['status'] ?? '').toString();

    final bool deactivated = (isActive == false) ||
        status.toLowerCase() == 'deactivated';

    final initials = firstName.isNotEmpty
        ? (firstName[0] + (lastName.isNotEmpty ? lastName[0] : '')).toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: deactivated
                ? const Color(0xFFFFEBEE)
                : const Color(0xFFE8F5E9),
            child: Text(initials,
                style: TextStyle(
                    fontSize: 20,
                    color: deactivated
                        ? const Color(0xFFC62828)
                        : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '$firstName $lastName'.trim().isEmpty
                        ? 'Unknown'
                        : '$firstName $lastName',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email,
                    style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(role,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: deactivated
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                          deactivated
                              ? 'Deactivated'
                              : (status.isNotEmpty ? status : 'Active'),
                          style: TextStyle(
                              fontSize: 10,
                              color: deactivated
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
          const Text('Financial Summary',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Income',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('Rs ${_totalIncome.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Entries',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${_income.length}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Text('$count',
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildIncomeTile(Map<String, dynamic> item) {
    final amount = _parseAmount(item['amount']);
    final source = (item['source'] ?? 'Unknown').toString();
    final desc = (item['description'] ?? item['descript'] ?? '').toString();
    final date = (item['date'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: Color(0xFF2E7D32),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                if (desc.isNotEmpty)
                  Text(desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      const TextStyle(fontSize: 10, color: Colors.grey)),
                if (date.isNotEmpty)
                  Text(date.split('T').first,
                      style:
                      const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '+ Rs ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child:
      Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}