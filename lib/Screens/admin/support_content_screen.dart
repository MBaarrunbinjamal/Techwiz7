import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'shared_app_bar.dart';

class SupportContentScreen extends StatefulWidget {
  const SupportContentScreen({super.key});

  @override
  State<SupportContentScreen> createState() => _SupportContentScreenState();
}

class _SupportContentScreenState extends State<SupportContentScreen> {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  bool _isLoading = false;
  bool _isPublishing = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _coverImageController =
  TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _readTimeController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Map<String, dynamic>> _modules = [];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverImageController.dispose();
    _tagController.dispose();
    _readTimeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadModules() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await _db.child('learning').get();

      final List<Map<String, dynamic>> loadedModules = [];

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

        data.forEach((key, value) {
          if (value is Map) {
            final module = Map<String, dynamic>.from(value);

            module['id'] = key.toString();

            loadedModules.add(module);
          }
        });
      }

      loadedModules.sort((a, b) {
        final aTime = int.tryParse(
          a['publishedAt']?.toString() ?? '0',
        ) ??
            0;

        final bTime = int.tryParse(
          b['publishedAt']?.toString() ?? '0',
        ) ??
            0;

        return bTime.compareTo(aTime);
      });

      if (mounted) {
        setState(() {
          _modules = loadedModules;
        });
      }
    } catch (e) {
      debugPrint('Load modules failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load content: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _getFcmToken(String uid) async {
    try {
      final userSnap = await _db.child('users/$uid/fcmToken').get();

      if (!userSnap.exists) {
        debugPrint('No FCM token found for $uid');
        return null;
      }

      final value = userSnap.value;

      if (value == null) {
        debugPrint('FCM token is null for $uid');
        return null;
      }

      final token = value.toString().trim();

      if (token.isEmpty) {
        debugPrint('FCM token is empty for $uid');
        return null;
      }

      return token;
    } catch (e) {
      debugPrint('Failed to get FCM token for $uid: $e');
      return null;
    }
  }

  Future<void> _sendPushNotification({
    required String uid,
    required String title,
    required String body,
  }) async {
    try {
      final token = await _getFcmToken(uid);

      if (token == null || token.isEmpty) {
        debugPrint(
          'Push skipped for $uid because no FCM token exists',
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
          'https://notificationnode.vercel.app/send-notification',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
        }),
      );

      debugPrint(
        'FCM response for $uid: '
            '${response.statusCode} ${response.body}',
      );
    } catch (e) {
      debugPrint(
        'FCM notification failed for $uid: $e',
      );
    }
  }

  Future<void> _publishContent({
    required String title,
    required String description,
    required String coverImage,
    required String tag,
    required String readTime,
    required String content,
  }) async {
    if (_isPublishing) {
      return;
    }

    try {
      setState(() {
        _isPublishing = true;
      });

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

      if (postId == null) {
        throw Exception('Could not create learning content ID');
      }

      final usersSnap = await _db.child('users').get();

      if (usersSnap.exists && usersSnap.value is Map) {
        final users = Map<dynamic, dynamic>.from(
          usersSnap.value as Map,
        );

        final updates = <String, dynamic>{};

        for (final entry in users.entries) {
          final uid = entry.key.toString();

          final userData = entry.value is Map
              ? Map<dynamic, dynamic>.from(entry.value as Map)
              : <dynamic, dynamic>{};

          /*
           * Admin account does not need a notification token.
           * If an admin record exists inside users, skip it.
           */
          final role =
              userData['Role']?.toString().toLowerCase().trim() ?? '';

          if (role == 'admin') {
            continue;
          }

          final notificationKey = _db
              .child('notifications')
              .child(uid)
              .push()
              .key;

          if (notificationKey == null) {
            continue;
          }

          updates[
          'notifications/$uid/$notificationKey'] = {
            'title': 'New Learning Content',
            'body': 'Admin has published a new learning content',
            'type': 'learning',
            'refId': postId,
            'createdAt': now,
            'isRead': false,
            'isPinned': false,
          };
        }

        if (updates.isNotEmpty) {
          await _db.update(updates);
        }

        /*
         * Send system push notification to every user
         * who has an FCM token stored in:
         *
         * users/{uid}/fcmToken
         */
        for (final entry in users.entries) {
          final uid = entry.key.toString();

          final userData = entry.value is Map
              ? Map<dynamic, dynamic>.from(entry.value as Map)
              : <dynamic, dynamic>{};

          final role =
              userData['Role']?.toString().toLowerCase().trim() ?? '';

          if (role == 'admin') {
            continue;
          }

          await _sendPushNotification(
            uid: uid,
            title: 'New Learning Content',
            body: 'Admin has published a new learning content',
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Content published & notifications sent',
            ),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }

      _clearFields();

      await _loadModules();
    } catch (e) {
      debugPrint('Publish content failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    _coverImageController.clear();
    _tagController.clear();
    _readTimeController.clear();
    _contentController.clear();
  }

  Future<void> _showPublishDialog() async {
    _clearFields();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Publish Learning Content'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Enter learning content title',
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter short description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    controller: _coverImageController,
                    label: 'Cover Image URL',
                    hint: 'https://...',
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    controller: _tagController,
                    label: 'Tag',
                    hint: 'AI / Finance / Learning',
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    controller: _readTimeController,
                    label: 'Read Time',
                    hint: '5 min read',
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    controller: _contentController,
                    label: 'Content',
                    hint: 'Write your learning content...',
                    maxLines: 8,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isPublishing
                  ? null
                  : () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isPublishing
                  ? null
                  : () async {
                final title = _titleController.text.trim();
                final description =
                _descriptionController.text.trim();
                final coverImage =
                _coverImageController.text.trim();
                final tag = _tagController.text.trim();
                final readTime =
                _readTimeController.text.trim();
                final content =
                _contentController.text.trim();

                if (title.isEmpty ||
                    description.isEmpty ||
                    content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Title, description and content are required',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(context);

                await _publishContent(
                  title: title,
                  description: description,
                  coverImage: coverImage,
                  tag: tag,
                  readTime: readTime,
                  content: content,
                );
              },
              child: _isPublishing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text('Publish'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      final value = int.tryParse(
        timestamp?.toString() ?? '',
      );

      if (value == null || value == 0) {
        return '';
      }

      final date = DateTime.fromMillisecondsSinceEpoch(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(
        title: 'Learning Content',
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadModules,
        child: _modules.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'No learning content found',
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _modules.length,
          itemBuilder: (context, index) {
            final module = _modules[index];

            final title =
                module['title']?.toString() ?? '';

            final description =
                module['description']?.toString() ?? '';

            final tag =
                module['tag']?.toString() ?? '';

            final readTime =
                module['readTime']?.toString() ?? '';

            final coverImage =
                module['coverImage']?.toString() ?? '';

            final date =
            _formatDate(module['publishedAt']);

            return Card(
              margin: const EdgeInsets.only(
                bottom: 14,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    if (coverImage.isNotEmpty)
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(12),
                        child: Image.network(
                          coverImage,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return Container(
                              width: double.infinity,
                              height: 180,
                              alignment: Alignment.center,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (tag.isNotEmpty)
                          Chip(
                            label: Text(tag),
                          ),
                        if (readTime.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(readTime),
                        ],
                        const Spacer(),
                        if (date.isNotEmpty)
                          Text(date),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isPublishing ? null : _showPublishDialog,
        icon: const Icon(Icons.add),
        label: const Text('Publish Content'),
      ),
    );
  }
}