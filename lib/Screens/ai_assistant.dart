import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String API_URL =
      "https://pannypal-ai-server.vercel.app/api/chat";

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  List<ChatSession> _sessions = [];
  String? _currentSessionId;
  bool _isLoadingSessions = true;
  bool _isLoadingMessages = false;

  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  Map<String, dynamic> _userContext = {};

  String? _typingMessageId;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadUserContext();
    await _loadSessions();

    if (_sessions.isNotEmpty) {
      await _loadSession(_sessions.first.id);
    } else {
      await _createNewSession(silent: true);
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    final cleaned = v.toString().replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _loadUserContext() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final profileSnap = await _db.child('users/$uid').get();
      String name = 'Student';
      if (profileSnap.exists && profileSnap.value is Map) {
        final p = Map<String, dynamic>.from(profileSnap.value as Map);
        final first = (p['FirstName'] ?? '').toString();
        final last = (p['LastName'] ?? '').toString();
        final full = '$first $last'.trim();
        if (full.isNotEmpty) name = full;
      }

      double totalIncome = 0;
      double totalExpense = 0;
      int incomeCount = 0;
      int expenseCount = 0;
      final recentIncome = <Map<String, dynamic>>[];
      final recentExpense = <Map<String, dynamic>>[];

      try {
        final db = DatabaseHelper();
        final txns = await db.getTransactions(uid);

        for (final t in txns) {
          if (t.type == 'income') {
            totalIncome += t.amount;
            incomeCount++;
            if (recentIncome.length < 5) {
              recentIncome.add({
                'source': t.source,
                'amount': t.amount,
                'date': t.date.toIso8601String(),
              });
            }
          } else {
            totalExpense += t.amount;
            expenseCount++;
            if (recentExpense.length < 5) {
              recentExpense.add({
                'source': t.source,
                'amount': t.amount,
                'date': t.date.toIso8601String(),
              });
            }
          }
        }
      } catch (e) {
        debugPrint('SQLite read error: $e');
      }

      final goals = <String>[];
      try {
        final goalsSnap = await _db.child('goals').get();
        if (goalsSnap.exists && goalsSnap.value != null) {
          final raw = goalsSnap.value;
          final allGoals = <Map<String, dynamic>>[];
          if (raw is List) {
            for (final v in raw) {
              if (v is Map) allGoals.add(Map<String, dynamic>.from(v));
            }
          } else if (raw is Map) {
            final data = Map<String, dynamic>.from(raw);
            data.forEach((_, v) {
              if (v is Map) allGoals.add(Map<String, dynamic>.from(v));
            });
          }
          for (final g in allGoals) {
            final gUid =
            (g['userId'] ?? g['userid'] ?? g['uid'] ?? '').toString();
            if (gUid == uid) {
              final title = (g['title'] ?? 'Goal').toString();
              final saved = _parseAmount(g['saved']);
              final target = _parseAmount(g['target']);
              goals.add(
                  '$title: \$${saved.toStringAsFixed(2)} / \$${target.toStringAsFixed(2)}');
            }
          }
        }
      } catch (_) {}

      _userContext = {
        'name': name,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': totalIncome - totalExpense,
        'incomeCount': incomeCount,
        'expenseCount': expenseCount,
        'recentIncome': recentIncome,
        'recentExpense': recentExpense,
        'goals': goals,
      };
    } catch (e) {
      debugPrint('Context load error: $e');
    }
  }

  Future<void> _loadSessions() async {
    final uid = _uid;
    if (uid == null) {
      setState(() => _isLoadingSessions = false);
      return;
    }

    try {
      final snap = await _db.child('users/$uid/chats').get();
      final loaded = <ChatSession>[];

      if (snap.exists && snap.value != null) {
        final raw = snap.value;
        if (raw is Map) {
          final data = Map<String, dynamic>.from(raw);
          data.forEach((key, value) {
            if (value is Map) {
              final s = Map<String, dynamic>.from(value);
              loaded.add(ChatSession(
                id: key,
                name: (s['name'] ?? 'Chat').toString(),
                createdAt: (s['createdAt'] ?? 0) is num
                    ? (s['createdAt'] as num).toInt()
                    : 0,
                updatedAt: (s['updatedAt'] ?? 0) is num
                    ? (s['updatedAt'] as num).toInt()
                    : 0,
              ));
            }
          });
        }
      }

      loaded.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (!mounted) return;
      setState(() {
        _sessions = loaded;
        _isLoadingSessions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _createNewSession({bool silent = false}) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ref = _db.child('users/$uid/chats').push();
      final newId = ref.key!;

      await ref.set({
        'name': 'New Chat',
        'createdAt': now,
        'updatedAt': now,
      });

      if (!silent && mounted) {
        Navigator.pop(context);
      }

      await _loadSessions();
      await _loadSession(newId);
    } catch (e) {
      debugPrint('Create session failed: $e');
    }
  }

  Future<void> _loadSession(String sessionId) async {
    final uid = _uid;
    if (uid == null) return;

    _typingTimer?.cancel();

    setState(() {
      _currentSessionId = sessionId;
      _messages.clear();
      _isLoadingMessages = true;
      _typingMessageId = null;
    });

    try {
      final snap =
      await _db.child('users/$uid/chats/$sessionId/messages').get();

      final loaded = <ChatMessage>[];

      if (snap.exists && snap.value != null) {
        final raw = snap.value;
        final all = <Map<String, dynamic>>[];
        if (raw is Map) {
          final data = Map<String, dynamic>.from(raw);
          data.forEach((key, value) {
            if (value is Map) {
              final m = Map<String, dynamic>.from(value);
              m['_key'] = key;
              all.add(m);
            }
          });
        } else if (raw is List) {
          for (int i = 0; i < raw.length; i++) {
            final v = raw[i];
            if (v is Map) {
              final m = Map<String, dynamic>.from(v);
              m['_key'] = i.toString();
              all.add(m);
            }
          }
        }

        all.sort((a, b) {
          final ta = (a['time'] ?? 0) as num;
          final tb = (b['time'] ?? 0) as num;
          return ta.toInt().compareTo(tb.toInt());
        });

        for (final m in all) {
          loaded.add(ChatMessage(
            text: (m['text'] ?? '').toString(),
            isUser: m['isUser'] == true,
            time: DateTime.fromMillisecondsSinceEpoch(
                ((m['time'] ?? 0) as num).toInt()),
            isError: m['isError'] == true,
            id: m['_key']?.toString(),
          ));
        }
      }

      if (loaded.isEmpty) {
        loaded.add(ChatMessage(
          text:
          "Hi! I'm your BudgetBee AI 🐝 Ask me anything about your budget, savings, or spending.",
          isUser: false,
          time: DateTime.now(),
          id: 'welcome',
        ));
      }

      if (!mounted) return;
      setState(() {
        _messages.addAll(loaded);
        _isLoadingMessages = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMessages = false);
    }
  }

  Future<void> _saveMessage(ChatMessage msg) async {
    final uid = _uid;
    final sid = _currentSessionId;
    if (uid == null || sid == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ref = _db.child('users/$uid/chats/$sid/messages').push();
      await ref.set({
        'text': msg.text,
        'isUser': msg.isUser,
        'time': msg.time.millisecondsSinceEpoch,
        'isError': msg.isError,
      });
      await _db.child('users/$uid/chats/$sid').update({
        'updatedAt': now,
      });
    } catch (e) {
      debugPrint('Save message failed: $e');
    }
  }

  Future<void> _renameSession(String sessionId, String newName) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.child('users/$uid/chats/$sessionId').update({
        'name': newName,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      await _loadSessions();
    } catch (e) {
      debugPrint('Rename failed: $e');
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.child('users/$uid/chats/$sessionId').remove();
      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
        _messages.clear();
      }
      await _loadSessions();

      if (_sessions.isNotEmpty) {
        await _loadSession(_sessions.first.id);
      } else {
        await _createNewSession(silent: true);
      }
    } catch (e) {
      debugPrint('Delete failed: $e');
    }
  }

  void _showRenameDialog(ChatSession session) {
    final ctrl = TextEditingController(text: session.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter chat name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              Navigator.pop(ctx);
              if (newName.isNotEmpty) {
                _renameSession(session.id, newName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _startTyping(String fullText) {
    _typingTimer?.cancel();
    _typingMessageId = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      _messages.add(ChatMessage(
        text: '',
        isUser: false,
        time: DateTime.now(),
        id: _typingMessageId!,
      ));
    });

    int i = 0;
    final chunkSize = fullText.length > 600 ? 4 : 3;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 18), (t) {
      if (i >= fullText.length) {
        t.cancel();
        final finalMsg = ChatMessage(
          text: fullText,
          isUser: false,
          time: DateTime.now(),
          id: _typingMessageId!,
        );
        setState(() {
          final idx =
          _messages.indexWhere((m) => m.id == _typingMessageId);
          if (idx != -1) _messages[idx] = finalMsg;
          _typingMessageId = null;
        });
        _saveMessage(finalMsg);
        _scrollToBottom();
        return;
      }

      i += chunkSize;
      if (i > fullText.length) i = fullText.length;

      final partial = fullText.substring(0, i);
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == _typingMessageId);
        if (idx != -1) {
          _messages[idx] = ChatMessage(
            text: partial,
            isUser: false,
            time: _messages[idx].time,
            id: _typingMessageId!,
          );
        }
      });
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final userMsg = ChatMessage(
      text: text.trim(),
      isUser: true,
      time: DateTime.now(),
      id: DateTime.now().microsecondsSinceEpoch.toString(),
    );

    setState(() {
      _messages.add(userMsg);
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();
    await _saveMessage(userMsg);

    if (_messages.where((m) => m.isUser).length == 1 &&
        _currentSessionId != null) {
      final autoName = text.trim().length > 28
          ? '${text.trim().substring(0, 28)}...'
          : text.trim();
      _db
          .child('users/${_uid}/chats/$_currentSessionId')
          .update({'name': autoName}).then((_) => _loadSessions());
    }

    try {
      await _loadUserContext();

      final history = _messages
          .where((m) => !m.isError && m.id != _typingMessageId)
          .skip(1)
          .toList();
      if (history.isNotEmpty) history.removeLast();

      final historyPayload = history
          .map((m) => {
        "role": m.isUser ? "user" : "assistant",
        "content": m.text,
      })
          .toList();

      final response = await http
          .post(
        Uri.parse(API_URL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": text.trim(),
          "history": historyPayload,
          "userContext": _userContext,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["reply"] ?? "Sorry, I couldn't respond.";

        setState(() {
          _isSending = false;
        });

        _startTyping(reply);
      } else {
        final errMsg = ChatMessage(
          text: "Oops! Server error (${response.statusCode}). Try again.",
          isUser: false,
          time: DateTime.now(),
          isError: true,
          id: DateTime.now().microsecondsSinceEpoch.toString(),
        );
        setState(() {
          _messages.add(errMsg);
          _isSending = false;
        });
        _saveMessage(errMsg);
      }
    } catch (e) {
      final errMsg = ChatMessage(
        text: "Network error. Check your internet connection.",
        isUser: false,
        time: DateTime.now(),
        isError: true,
        id: DateTime.now().microsecondsSinceEpoch.toString(),
      );
      setState(() {
        _messages.add(errMsg);
        _isSending = false;
      });
      _saveMessage(errMsg);
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<InlineSpan> _formatText(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(fontWeight: FontWeight.normal),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(fontWeight: FontWeight.normal),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
              _isSending
                  ? "Thinking..."
                  : "Personalized student financial advice",
              style: GoogleFonts.poppins(
                color: _isSending ? Colors.green[700] : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined,
                color: Colors.black),
            tooltip: 'New Chat',
            onPressed: () => _createNewSession(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 16),
                if (_messages.length <= 1) ...[
                  _buildSuggestedPrompts(),
                  const SizedBox(height: 16),
                ],
                ..._messages.asMap().entries.map((entry) {
                  return _AnimatedBubble(
                    key: ValueKey(
                        entry.value.id ?? entry.key.toString()),
                    child: _buildMessageBubble(entry.value),
                  );
                }),
                if (_isSending) _buildTypingIndicator(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF5F7FA),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    Colors.white.withValues(alpha: 0.2),
                    child:
                    const Icon(Icons.savings, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BudgetBee',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_sessions.length} chats',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _createNewSession(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoadingSessions
                  ? const Center(child: CircularProgressIndicator())
                  : _sessions.isEmpty
                  ? Center(
                child: Text(
                  'No chats yet',
                  style: GoogleFonts.poppins(
                      color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, i) {
                  final s = _sessions[i];
                  final isActive =
                      s.id == _currentSessionId;
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE8F5E9)
                          : Colors.transparent,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: isActive
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[700],
                      ),
                      title: Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      trailing:
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 18),
                        onSelected: (val) {
                          if (val == 'rename') {
                            _showRenameDialog(s);
                          } else if (val == 'delete') {
                            _confirmDelete(s);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Rename'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 16,
                                    color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(
                                        color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _loadSession(s.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ChatSession s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete chat?'),
        content: Text('"${s.name}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSession(s.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
                  "Hi! I'm your BudgetBee AI 🐝 Ask me anything about your budget, savings, or spending.",
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
    );
  }

  Widget _buildSuggestedPrompts() {
    final prompts = [
      {
        "text": "What is my balance?",
        "icon": Icons.account_balance_wallet
      },
      {"text": "How much did I spend?", "icon": Icons.receipt_long},
      {"text": "Help me save \$500", "icon": Icons.savings},
      {"text": "Meal prep tips?", "icon": Icons.lunch_dining},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              "Tap to ask",
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
            children: prompts.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => _sendMessage(p["text"] as String),
                  child: _buildPromptChip(
                    p["text"] as String,
                    p["icon"] as IconData,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptChip(String text, IconData icon) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 40),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 300),
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
                  msg.text,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(msg.time),
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all,
                        color: Colors.greenAccent, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF3E0),
            radius: 16,
            child: Icon(Icons.cruelty_free,
                color: Colors.orange[800], size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                msg.isError ? const Color(0xFFFFEBEE) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: msg.isError
                        ? Colors.red[400]!
                        : Colors.green[600]!,
                    width: 4,
                  ),
                  top: BorderSide(color: Colors.grey.shade200),
                  right: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.text.isEmpty)
                    _buildTypingDotsInline()
                  else
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        children: _formatText(msg.text),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        _formatTime(msg.time),
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.thumb_up_alt_outlined,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Icon(Icons.thumb_down_alt_outlined,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        "BudgetBee v2.4",
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDotsInline() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(0),
        const SizedBox(width: 4),
        _dot(150),
        const SizedBox(width: 4),
        _dot(300),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF3E0),
            radius: 16,
            child: Icon(Icons.cruelty_free,
                color: Colors.orange[800], size: 18),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(150),
                const SizedBox(width: 4),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
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
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: "Ask BudgetBee anything...",
                          hintStyle:
                          GoogleFonts.poppins(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isSending
                  ? null
                  : () => _sendMessage(_controller.text),
              child: CircleAvatar(
                backgroundColor: _isSending
                    ? Colors.grey[400]
                    : const Color(0xFF00C853),
                radius: 24,
                child: _isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.arrow_upward,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return "$h:$m $ap";
  }
}

class _AnimatedBubble extends StatefulWidget {
  final Widget child;

  const _AnimatedBubble({Key? key, required this.child})
      : super(key: key);

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;
  final String? id;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
    this.id,
  });
}

class ChatSession {
  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;

  ChatSession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}