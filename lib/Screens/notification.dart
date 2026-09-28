import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:techwiz7/Services/PrefsService.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with WidgetsBindingObserver {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _soundInitialized = false;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    await _requestPermission();
    await _saveToken();
    _listenRefresh();
    _listenForegroundMessages();
    _listenNotifications();
  }

  Future<void> _requestPermission() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Permission error: $e');
    }
  }

  Future<void> _saveToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await PrefsService.instance.saveToken(token);
      await _db.child('users/$uid/fcmToken').set(token);
      debugPrint('FCM token saved: $token');
    } catch (e) {
      debugPrint('Save FCM token error: $e');
    }
  }

  void _listenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        await PrefsService.instance.saveToken(newToken);
        await _db.child('users/$uid/fcmToken').set(newToken);
      } catch (e) {
        debugPrint('Token refresh error: $e');
      }
    });
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('Foreground message: ${msg.notification?.title}');
      _playNotificationSound();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              msg.notification?.title ?? 'New notification'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _saveToken();
    }
  }

  void _listenNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _db.child('notifications/$uid').onValue.listen(
          (event) {
        final snap = event.snapshot;
        final loaded = <Map<String, dynamic>>[];

        if (snap.exists && snap.value != null) {
          final raw = snap.value;
          if (raw is Map) {
            raw.forEach((key, value) {
              if (value is Map) {
                final item = Map<String, dynamic>.from(value);
                item['_key'] = key.toString();
                loaded.add(item);
              }
            });
          } else if (raw is List) {
            for (int i = 0; i < raw.length; i++) {
              final value = raw[i];
              if (value is Map) {
                final item = Map<String, dynamic>.from(value);
                item['_key'] = i.toString();
                loaded.add(item);
              }
            }
          }
        }

        loaded.sort((a, b) {
          final pa = a['isPinned'] == true ? 1 : 0;
          final pb = b['isPinned'] == true ? 1 : 0;
          if (pa != pb) return pb.compareTo(pa);
          final ta = _ts(a['createdAt']);
          final tb = _ts(b['createdAt']);
          return tb.compareTo(ta);
        });

        if (_soundInitialized && loaded.length > _lastCount) {
          _playNotificationSound();
        }
        _soundInitialized = true;
        _lastCount = loaded.length;

        if (!mounted) return;
        setState(() {
          _notifications = loaded;
          _isLoading = false;
        });
      },
      onError: (error) {
        debugPrint('Listener error: $error');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  int _ts(dynamic v) {
    if (v is num) return v.toInt();
    return 0;
  }

  void _playNotificationSound() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 180), () {
      SystemSound.play(SystemSoundType.alert);
    });
    Future.delayed(const Duration(milliseconds: 360), () {
      SystemSound.play(SystemSoundType.alert);
    });
  }

  Future<void> _markRead(String key) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || key.isEmpty) return;
    try {
      await _db.child('notifications/$uid/$key').update({'isRead': true});
    } catch (_) {}
  }

  Future<void> _togglePin(String key, bool current) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || key.isEmpty) return;
    try {
      await _db
          .child('notifications/$uid/$key')
          .update({'isPinned': !current});
    } catch (_) {}
  }

  Future<void> _clearAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _db.child('notifications/$uid').remove();
    } catch (e) {
      debugPrint('Clear error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.greenDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: const Text('Clear all',
                style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _saveToken,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_notifications.isEmpty)
                _emptyState()
              else ...[
                _summary(),
                const SizedBox(height: 20),
                _header('ALL NOTIFICATIONS',
                    '${_notifications.length} total'),
                const SizedBox(height: 10),
                ..._notifications
                    .map((n) => _card(n)),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PennyBottomNav(currentIndex: 0),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: AppColors.fill, shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none,
                  color: AppColors.muted, size: 40),
            ),
            const SizedBox(height: 16),
            const Text("You're all caught up!",
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.ink)),
            const SizedBox(height: 6),
            const Text(
              'No new notifications right now.\nWe\'ll alert you when something happens.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary() {
    final unread =
        _notifications.where((n) => n['isRead'] != true).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: AppColors.amberSoft, shape: BoxShape.circle),
            child:
            const Icon(Icons.emoji_events, color: AppColors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Notifications',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.ink)),
                Text('$unread unread',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          if (unread > 0)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.redSoft,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$unread new',
                  style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }

  Widget _header(String d, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(d,
            style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1)),
        Text(right,
            style:
            const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }

  Widget _card(Map<String, dynamic> n) {
    final title = (n['title'] ?? 'Notification').toString();
    final body = (n['body'] ?? '').toString();
    final type = (n['type'] ?? 'alert').toString();
    final isRead = n['isRead'] == true;
    final isPinned = n['isPinned'] == true;
    final createdAt = n['createdAt'] ?? 0;
    final key = (n['_key'] ?? '').toString();

    IconData icon = Icons.notifications;
    Color icoCol = AppColors.blue;
    Color icoBg = AppColors.blueSoft;

    if (type == 'learning') {
      icon = Icons.menu_book;
      icoCol = AppColors.green;
      icoBg = AppColors.greenSoft;
    } else if (type == 'alert') {
      icon = Icons.warning_amber_rounded;
      icoCol = AppColors.red;
      icoBg = AppColors.redSoft;
    } else if (type == 'goal') {
      icon = Icons.emoji_events;
      icoCol = AppColors.amber;
      icoBg = AppColors.amberSoft;
    } else if (type == 'support') {
      icon = Icons.support_agent;
      icoCol = AppColors.blue;
      icoBg = AppColors.blueSoft;
    }

    return GestureDetector(
      onTap: () async {
        await _markRead(key);
        if (!mounted) return;
        if (type == 'learning') {
          Navigator.pushNamed(context, '/learning');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isRead
                  ? AppColors.track
                  : AppColors.green.withValues(alpha: 0.5),
              width: isRead ? 1 : 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration:
                  BoxDecoration(color: icoBg, shape: BoxShape.circle),
                  child: Icon(icon, color: icoCol, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (isPinned)
                            const Icon(Icons.push_pin,
                                size: 14, color: AppColors.green),
                          if (!isRead)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(body,
                          style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(_fmt(createdAt),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _togglePin(key, isPinned),
                  child: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 16,
                    color: isPinned ? AppColors.green : AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic ts) {
    final v = _ts(ts);
    if (v == 0) return '';
    try {
      final d = DateTime.fromMillisecondsSinceEpoch(v);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }
}