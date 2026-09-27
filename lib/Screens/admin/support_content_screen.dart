import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shared_app_bar.dart';

class SupportContentScreen extends StatefulWidget {
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  const SupportContentScreen({
    Key? key,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  State<SupportContentScreen> createState() => _SupportContentScreenState();
}

class _SupportContentScreenState extends State<SupportContentScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  int tabIndex = 0;
  String filter = 'All';

  final List<Map<String, dynamic>> queries = [
    {
      'name': 'Sarah Jenkins',
      'id': '#1043',
      'time': '25m ago',
      'status': 'In Review',
      'urgent': true,
      'title': 'Receipt scanner failed to recognize dining hall invoice',
      'description':
      '"The camera scanned the receipt but the total showed \$0.00 instead of \$14.50..."',
      'detailed': true,
    },
    {
      'name': 'Liam Wong',
      'id': '#1041',
      'time': '1h ago',
      'status': 'Pending Response',
      'urgent': false,
      'title': 'How to change currency from USD to EUR?',
      'description': '',
      'detailed': false,
    },
  ];

  List<Map<String, dynamic>> _modules = [];
  bool _isLoadingModules = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() => _isLoadingModules = true);
    try {
      final snap = await _db.child('learning').get();
      final List<Map<String, dynamic>> loaded = [];

      if (snap.exists && snap.value != null) {
        final raw = snap.value;
        if (raw is Map) {
          final data = Map<String, dynamic>.from(raw);
          data.forEach((key, value) {
            if (value is Map) {
              final item = Map<String, dynamic>.from(value);
              item['_key'] = key;
              loaded.add(item);
            }
          });
        } else if (raw is List) {
          for (int i = 0; i < raw.length; i++) {
            final v = raw[i];
            if (v is Map) {
              final item = Map<String, dynamic>.from(v);
              item['_key'] = i.toString();
              loaded.add(item);
            }
          }
        }
      }

      loaded.sort((a, b) {
        final ta = (a['publishedAt'] ?? 0) as num;
        final tb = (b['publishedAt'] ?? 0) as num;
        return tb.toInt().compareTo(ta.toInt());
      });

      setState(() {
        _modules = loaded;
        _isLoadingModules = false;
      });
    } catch (e) {
      setState(() => _isLoadingModules = false);
    }
  }

  List<Map<String, dynamic>> get filteredQueries {
    if (filter == 'Urgent')
      return queries.where((q) => q['urgent'] == true).toList();
    if (filter == 'General')
      return queries.where((q) => q['urgent'] == false).toList();
    if (filter == 'Resolved')
      return queries.where((q) => q['status'] == 'Resolved').toList();
    return queries;
  }

  Future<void> _publishContent({
    required String title,
    required String description,
    required String coverImage,
    required String tag,
    required String readTime,
    required String content,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final user = FirebaseAuth.instance.currentUser;

      final ref = _db.child('learning').push();
      await ref.set({
        'title': title,
        'description': description,
        'coverImage': coverImage,
        'tag': tag,
        'readTime': readTime,
        'content': content,
        'publishedBy': user?.email ?? 'admin',
        'publishedAt': now,
        'isActive': true,
      });

      final postId = ref.key;

      final usersSnap = await _db.child('users').get();
      if (usersSnap.exists && usersSnap.value is Map) {
        final users = Map<String, dynamic>.from(usersSnap.value as Map);
        final updates = <String, dynamic>{};

        users.forEach((uid, _) {
          final notifRef = _db.child('notifications/$uid').push();
          updates['notifications/$uid/${notifRef.key}'] = {
            'title': 'New Learning Content',
            'body': 'Admin uploaded: "$title"',
            'type': 'learning',
            'refId': postId ?? '',
            'createdAt': now,
            'isRead': false,
            'isPinned': false,
          };
        });

        if (updates.isNotEmpty) {
          await _db.update(updates);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Content published & notifications sent'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      _loadModules();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteContent(String key) async {
    try {
      await _db.child('learning/$key').remove();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Deleted')));
      }
      _loadModules();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _toggleModuleActive(String key, bool current) async {
    try {
      await _db.child('learning/$key').update({'isActive': !current});
      _loadModules();
    } catch (_) {}
  }

  void _showAddContentDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'Beginner');
    final readCtrl = TextEditingController(text: '4 min read');
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish New Content'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration:
                const InputDecoration(labelText: 'Short Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imgCtrl,
                decoration: const InputDecoration(
                    labelText: 'Cover Image URL',
                    hintText: 'https://images.unsplash.com/...'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tagCtrl,
                decoration:
                const InputDecoration(labelText: 'Tag (Beginner, Saving)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: readCtrl,
                decoration: const InputDecoration(labelText: 'Read Time'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Full Content'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _publishContent(
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                coverImage: imgCtrl.text.trim(),
                tag: tagCtrl.text.trim(),
                readTime: readCtrl.text.trim(),
                content: contentCtrl.text.trim(),
              );
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: 'Support & Content',
        subtitle: 'Manage student requests & modules',
        showProfileIcon: true,
        onOpenNotifications: widget.onOpenNotifications,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggleTabs(),
            const SizedBox(height: 16),
            if (tabIndex == 0) ...[
              _buildFilterRow(),
              const SizedBox(height: 16),
              ...filteredQueries.map((q) => q['detailed'] == true
                  ? _buildSupportTicketCard(q)
                  : _buildSimpleTicketCard(q)),
            ] else ...[
              _buildFinancialModules(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildTabButton('Support Queries', 0,
                  Icons.support_agent, '${queries.length}')),
          Expanded(
              child: _buildTabButton('Learning Content', 1,
                  Icons.menu_book, '${_modules.length}')),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      String label, int index, IconData icon, String count) {
    final isActive = tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isActive
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.grey),
              ),
            ),
            const SizedBox(width: 4),
            Text(count,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', 'All', true),
          const SizedBox(width: 8),
          _buildFilterChip('Urgent', 'Urgent', false,
              const Color(0xFFFFEBEE), const Color(0xFFC62828)),
          const SizedBox(width: 8),
          _buildFilterChip('General', 'General', false),
          const SizedBox(width: 8),
          _buildFilterChip('Resolved', 'Resolved', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isFirst,
      [Color? bgColor, Color? textColor]) {
    final isActive = filter == value;
    return GestureDetector(
      onTap: () => setState(() => filter = value),
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
                : (textColor ??
                Theme.of(context).textTheme.bodyLarge?.color),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSupportTicketCard(Map<String, dynamic> q) {
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
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFF3E0),
                child: Text(q['name'][0],
                    style: const TextStyle(
                        color: Color(0xFFEF6C00),
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q['name'],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(q['id'],
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(q['status'],
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFEF6C00),
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(q['time'],
                  style:
                  const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(q['title'],
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          if ((q['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(q['description'],
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type admin reply to student...',
              hintStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child:
                const Text('Reassign', style: TextStyle(fontSize: 12)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Response sent & ticket resolved')),
                  );
                },
                icon: const Icon(Icons.send, size: 14),
                label: const Text('Send & Resolve',
                    style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTicketCard(Map<String, dynamic> q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE3F2FD),
            child: Text(q['name'][0],
                style: const TextStyle(
                    color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                        child: Text(q['name'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Text(q['id'],
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)),
                  ],
                ),
                Text(q['title'],
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8)),
            child: Text(q['status'],
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFEF6C00),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Literacy Modules',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Published content from Firebase',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddContentDialog,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add New',
                  style: TextStyle(fontSize: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingModules)
          const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ))
        else if (_modules.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: const [
                Icon(Icons.menu_book, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No content yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 4),
                Text('Tap "Add New" to publish',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          )
        else
          ..._modules.map((m) => _buildModuleCard(m)),
      ],
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> m) {
    final title = (m['title'] ?? 'Untitled').toString();
    final desc = (m['description'] ?? '').toString();
    final tag = (m['tag'] ?? 'General').toString();
    final readTime = (m['readTime'] ?? '3 min read').toString();
    final isActive = m['isActive'] != false;
    final publishedAt = m['publishedAt'] ?? 0;
    final key = m['_key'] ?? '';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$tag • $readTime',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              Switch(
                value: isActive,
                onChanged: (_) => _toggleModuleActive(key, isActive),
                activeColor: const Color(0xFF2E7D32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(desc,
                style:
                const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Text('Published: ${_formatDate(publishedAt)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Duplicated (demo)')),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.copy, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Duplicate',
                        style:
                        TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _deleteContent(key),
                child: Row(
                  children: const [
                    Icon(Icons.delete,
                        size: 14, color: Color(0xFFC62828)),
                    SizedBox(width: 4),
                    Text('Delete',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFFC62828))),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child:
                const Text('Edit', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'Unknown';
    try {
      final dt =
      DateTime.fromMillisecondsSinceEpoch((ts as num).toInt());
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Unknown';
    }
  }
}