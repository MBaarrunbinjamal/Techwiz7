import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'shared_app_bar.dart';

class SupportContentScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const SupportContentScreen({
    super.key,
    this.onOpenSettings,
  });

  @override
  State<SupportContentScreen> createState() => _SupportContentScreenState();
}

class _SupportContentScreenState extends State<SupportContentScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  int _tab = 0;

  bool _loadingLearning = false;
  bool _loadingFeedback = false;
  bool _loadingSupport = false;
  bool _publishing = false;

  List<Map<String, dynamic>> _modules = [];
  List<Map<String, dynamic>> _feedback = [];
  List<Map<String, dynamic>> _support = [];

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _readCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imgCtrl.dispose();
    _tagCtrl.dispose();
    _readCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadLearning(),
      _loadFeedback(),
      _loadSupport(),
    ]);
  }

  Future<void> _loadLearning() async {
    setState(() => _loadingLearning = true);
    try {
      final snap = await _db.child('learning').get();
      final list = <Map<String, dynamic>>[];
      if (snap.exists && snap.value != null) {
        final raw = snap.value;
        if (raw is Map) {
          final d = Map<String, dynamic>.from(raw);
          d.forEach((k, v) {
            if (v is Map) {
              final m = Map<String, dynamic>.from(v);
              m['_key'] = k;
              list.add(m);
            }
          });
        } else if (raw is List) {
          for (int i = 0; i < raw.length; i++) {
            final v = raw[i];
            if (v is Map) {
              final m = Map<String, dynamic>.from(v);
              m['_key'] = i.toString();
              list.add(m);
            }
          }
        }
      }
      list.sort((a, b) {
        final ta = int.tryParse(a['publishedAt']?.toString() ?? '0') ?? 0;
        final tb = int.tryParse(b['publishedAt']?.toString() ?? '0') ?? 0;
        return tb.compareTo(ta);
      });
      if (mounted) setState(() => _modules = list);
    } catch (e) {
      debugPrint('load learning error: $e');
    } finally {
      if (mounted) setState(() => _loadingLearning = false);
    }
  }

  Future<void> _loadFeedback() async {
    setState(() => _loadingFeedback = true);
    try {
      final snap = await _db.child('feedback').get();
      final list = <Map<String, dynamic>>[];
      if (snap.exists && snap.value != null) {
        final raw = snap.value;
        if (raw is Map) {
          final d = Map<String, dynamic>.from(raw);
          d.forEach((k, v) {
            if (v is Map) {
              final m = Map<String, dynamic>.from(v);
              m['_key'] = k;
              list.add(m);
            }
          });
        } else if (raw is List) {
          for (int i = 0; i < raw.length; i++) {
            final v = raw[i];
            if (v is Map) {
              final m = Map<String, dynamic>.from(v);
              m['_key'] = i.toString();
              list.add(m);
            }
          }
        }
      }
      list.sort((a, b) {
        final ta = (a['date'] ?? '').toString();
        final tb = (b['date'] ?? '').toString();
        return tb.compareTo(ta);
      });
      if (mounted) setState(() => _feedback = list);
    } catch (e) {
      debugPrint('load feedback error: $e');
    } finally {
      if (mounted) setState(() => _loadingFeedback = false);
    }
  }

  Future<void> _loadSupport() async {
    setState(() => _loadingSupport = true);
    try {
      final snap = await _db.child('support').get();
      final list = <Map<String, dynamic>>[];
      if (snap.exists && snap.value != null) {
        final raw = snap.value;
        if (raw is Map) {
          final d = Map<String, dynamic>.from(raw);
          d.forEach((k, v) {
            if (v is Map) {
              final m = Map<String, dynamic>.from(v);
              m['_key'] = k;
              list.add(m);
            }
          });
        } else if (raw is List) {
          for (int i = 0; i < raw.length; i++) {
            final v = raw[i];
            if (v is Map) {
              final m = Map<String, dynamic>.from(v);
              m['_key'] = i.toString();
              list.add(m);
            }
          }
        }
      }
      list.sort((a, b) {
        final ta = (a['date'] ?? '').toString();
        final tb = (b['date'] ?? '').toString();
        return tb.compareTo(ta);
      });
      if (mounted) setState(() => _support = list);
    } catch (e) {
      debugPrint('load support error: $e');
    } finally {
      if (mounted) setState(() => _loadingSupport = false);
    }
  }

  Future<void> _publish() async {
    if (_publishing) return;
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final img = _imgCtrl.text.trim();
    final tag = _tagCtrl.text.trim();
    final read = _readCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty || desc.isEmpty || content.isEmpty) {
      _snack('Title, description and content are required', Colors.red);
      return;
    }

    setState(() => _publishing = true);
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final user = FirebaseAuth.instance.currentUser;
      final ref = _db.child('learning').push();
      await ref.set({
        'title': title,
        'description': desc,
        'coverImage': img,
        'tag': tag.isEmpty ? 'General' : tag,
        'readTime': read.isEmpty ? '3 min read' : read,
        'content': content,
        'publishedBy': user?.email ?? 'admin',
        'publishedAt': now,
        'isActive': true,
      });

      final postId = ref.key ?? '';

      final usersSnap = await _db.child('users').get();
      if (usersSnap.exists && usersSnap.value is Map) {
        final users = Map<dynamic, dynamic>.from(usersSnap.value as Map);
        final updates = <String, dynamic>{};
        final uidsToNotify = <String>[];

        for (final entry in users.entries) {
          final uid = entry.key.toString();
          final userData = entry.value is Map
              ? Map<dynamic, dynamic>.from(entry.value as Map)
              : <dynamic, dynamic>{};
          final role = userData['Role']?.toString().toLowerCase() ?? '';
          if (role == 'admin') continue;

          final nkey =
              _db.child('notifications').child(uid).push().key ?? '';
          if (nkey.isEmpty) continue;

          updates['notifications/$uid/$nkey'] = {
            'title': 'New Learning Content',
            'body': 'Admin has published: "$title"',
            'type': 'learning',
            'refId': postId,
            'createdAt': now,
            'isRead': false,
            'isPinned': false,
          };
          uidsToNotify.add(uid);
        }

        if (updates.isNotEmpty) {
          await _db.update(updates);
        }

        for (final uid in uidsToNotify) {
          await _sendPush(uid, 'New Learning Content',
              'Admin has published: "$title"');
        }
      }

      _clear();
      _snack('Content published & notifications sent', const Color(0xFF2E7D32));
      await _loadLearning();
    } catch (e) {
      _snack('Failed: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _sendPush(String uid, String title, String body) async {
    try {
      final tokenSnap = await _db.child('users/$uid/fcmToken').get();
      if (!tokenSnap.exists || tokenSnap.value == null) return;
      final token = tokenSnap.value.toString().trim();
      if (token.isEmpty) return;

      await http.post(
        Uri.parse('https://notificationnode.vercel.app/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
        }),
      );
    } catch (_) {}
  }

  Future<void> _toggleLearning(String key, bool current) async {
    try {
      await _db.child('learning/$key').update({'isActive': !current});
      await _loadLearning();
    } catch (e) {
      _snack('Toggle failed: $e', Colors.red);
    }
  }

  Future<void> _deleteLearning(String key) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this content?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _db.child('learning/$key').remove();
      await _loadLearning();
      _snack('Deleted', Colors.grey);
    } catch (e) {
      _snack('Delete failed: $e', Colors.red);
    }
  }

  Future<void> _replySupport(Map<String, dynamic> ticket) async {
    final ctrl = TextEditingController(text: ticket['adminReply'] ?? '');
    final reply = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reply to student'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Type your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );

    if (reply == null || reply.isEmpty) return;

    try {
      final key = ticket['_key'].toString();
      final userId = (ticket['userId'] ?? '').toString();
      final subject = (ticket['subject'] ?? 'Support').toString();
      final now = DateTime.now().millisecondsSinceEpoch;

      await _db.child('support/$key').update({
        'adminReply': reply,
        'status': 'replied',
        'repliedAt': now,
      });

      if (userId.isNotEmpty) {
        final nkey = _db.child('notifications').child(userId).push().key ?? '';
        if (nkey.isNotEmpty) {
          await _db.child('notifications/$userId/$nkey').set({
            'title': 'Support Reply',
            'body': 'Admin replied to "$subject": $reply',
            'type': 'support',
            'refId': key,
            'createdAt': now,
            'isRead': false,
            'isPinned': false,
          });
        }
        await _sendPush(userId, 'Support Reply',
            'Admin replied to "$subject"');
      }

      await _loadSupport();
      _snack('Reply sent', const Color(0xFF2E7D32));
    } catch (e) {
      _snack('Reply failed: $e', Colors.red);
    }
  }

  void _clear() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _imgCtrl.clear();
    _tagCtrl.clear();
    _readCtrl.clear();
    _contentCtrl.clear();
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  Future<void> _showPublishDialog() async {
    _clear();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Learning Content'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_titleCtrl, 'Title', 'Enter title'),
                const SizedBox(height: 12),
                _field(_descCtrl, 'Description', 'Short description',
                    maxLines: 2),
                const SizedBox(height: 12),
                _field(_imgCtrl, 'Cover Image URL', 'https://...'),
                const SizedBox(height: 12),
                _field(_tagCtrl, 'Tag', 'Beginner / Saving'),
                const SizedBox(height: 12),
                _field(_readCtrl, 'Read Time', '4 min read'),
                const SizedBox(height: 12),
                _field(_contentCtrl, 'Content', 'Write content...',
                    maxLines: 6),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:
            _publishing ? null : () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _publishing
                ? null
                : () async {
              Navigator.pop(ctx);
              await _publish();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: _publishing
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Text('Publish'),
          ),
        ],
      ),
    );
  }

  Widget _field(
      TextEditingController c,
      String label,
      String hint, {
        int maxLines = 1,
      }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String _fmtDate(dynamic ts) {
    if (ts == null) return '';
    try {
      final v = int.tryParse(ts.toString()) ?? 0;
      if (v == 0) return '';
      final d = DateTime.fromMillisecondsSinceEpoch(v);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: 'Support & Content',
        subtitle: 'Manage students & content',
        showProfileIcon: false,
        onOpenSettings: widget.onOpenSettings ?? () {},
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
        onPressed: _publishing ? null : _showPublishDialog,
        icon: const Icon(Icons.add),
        label: const Text('Publish'),
      )
          : null,
    );
  }

  Widget _buildTabs() {
    final tabs = ['Learning', 'Feedback', 'Support'];
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _tab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).cardColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      active ? FontWeight.bold : FontWeight.normal,
                      color: active ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_tab == 0) return _buildLearningTab();
    if (_tab == 1) return _buildFeedbackTab();
    return _buildSupportTab();
  }

  Widget _buildLearningTab() {
    if (_loadingLearning) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_modules.isEmpty) {
      return const Center(child: Text('No content yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadLearning,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _modules.length,
        itemBuilder: (context, i) {
          final m = _modules[i];
          final key = m['_key'].toString();
          final title = (m['title'] ?? '').toString();
          final desc = (m['description'] ?? '').toString();
          final tag = (m['tag'] ?? '').toString();
          final read = (m['readTime'] ?? '').toString();
          final img = (m['coverImage'] ?? '').toString();
          final active = m['isActive'] != false;
          final date = _fmtDate(m['publishedAt']);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('$tag • $read',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ),
                      Switch(
                        value: active,
                        onChanged: (_) => _toggleLearning(key, active),
                        activeColor: const Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                  if (img.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        img,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (date.isNotEmpty)
                        Text(date,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _deleteLearning(key),
                        icon: const Icon(Icons.delete,
                            size: 16, color: Colors.red),
                        label: const Text('Delete',
                            style: TextStyle(
                                fontSize: 11, color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackTab() {
    if (_loadingFeedback) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_feedback.isEmpty) {
      return const Center(child: Text('No feedback yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadFeedback,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _feedback.length,
        itemBuilder: (context, i) {
          final f = _feedback[i];
          final rating = f['rating'] ?? 0;
          final comments = (f['comments'] ?? '').toString();
          final date = (f['date'] ?? '').toString();
          final uid = (f['userId'] ?? '').toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(5, (idx) {
                        return Icon(
                          idx < (rating is int ? rating : 0)
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                      const Spacer(),
                      if (date.isNotEmpty)
                        Text(
                          date.length > 10 ? date.substring(0, 10) : date,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(comments,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('User: $uid',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupportTab() {
    if (_loadingSupport) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_support.isEmpty) {
      return const Center(child: Text('No support queries yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadSupport,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _support.length,
        itemBuilder: (context, i) {
          final s = _support[i];
          final subject = (s['subject'] ?? '').toString();
          final message = (s['message'] ?? '').toString();
          final email = (s['userEmail'] ?? '').toString();
          final status = (s['status'] ?? 'open').toString();
          final reply = (s['adminReply'] ?? '').toString();
          final date = (s['date'] ?? '').toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(subject,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'replied'
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(status,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: status == 'replied'
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFEF6C00))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(message, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('$email • ${date.length > 10 ? date.substring(0, 10) : date}',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey)),
                  if (reply.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.reply,
                              size: 14, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('You: $reply',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2E7D32))),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _replySupport(s),
                      icon: const Icon(Icons.send, size: 14),
                      label: Text(
                          reply.isEmpty ? 'Reply' : 'Update Reply',
                          style: const TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}