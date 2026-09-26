import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // LIVE VERCEL URL
  static const String API_URL = "https://pannypal-ai-server.vercel.app/api/chat";

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat messages list
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Welcome message (local, sirf UI me dikhta hai)
    _messages.add(ChatMessage(
      text:
      "Hi! I'm your BudgetBee AI 🐝 Ask me anything about your budget, meal prep savings, or loan planning.",
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMsg = ChatMessage(
      text: text.trim(),
      isUser: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // History build karo (welcome msg skip karke)
      final history = _messages
          .skip(1)
          .take(_messages.length - 2)
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
          "history": history,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["reply"] ?? "Sorry, I couldn't respond.";

        setState(() {
          _messages.add(ChatMessage(
            text: reply,
            isUser: false,
            time: DateTime.now(),
          ));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: "Oops! Server error (${response.statusCode}). Try again.",
            isUser: false,
            time: DateTime.now(),
            isError: true,
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Network error. Check your internet connection.",
          isUser: false,
          time: DateTime.now(),
          isError: true,
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: "Chat cleared! How can I help you today? 🐝",
        isUser: false,
        time: DateTime.now(),
      ));
    });
  }

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
              _isLoading ? "Typing..." : "Personalized student financial advice",
              style: GoogleFonts.poppins(
                color: _isLoading ? Colors.green[700] : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _clearChat,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                // Welcome banner
                _buildWelcomeCard(),
                const SizedBox(height: 16),

                // Suggested prompts (only first few messages)
                if (_messages.length <= 2) ...[
                  _buildSuggestedPrompts(),
                  const SizedBox(height: 16),
                ],

                // Chat messages
                ..._messages.map((m) => _buildMessageBubble(m)),

                // Typing indicator
                if (_isLoading) _buildTypingIndicator(),

                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildInputBar(),
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
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  Widget _buildSuggestedPrompts() {
    final prompts = [
      {"text": "Can I afford dinner out?", "icon": Icons.restaurant},
      {"text": "How do I cut down coffee?", "icon": Icons.cut},
      {"text": "Help me save \$200", "icon": Icons.savings},
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

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      // User bubble (dark, right side)
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
                      color: Colors.white, fontSize: 14, height: 1.4),
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

    // AI bubble (white, left side, avatar ke saath)
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
                color: msg.isError ? const Color(0xFFFFEBEE) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: msg.isError ? Colors.red[400]! : Colors.green[600]!,
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
                  Text(
                    msg.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
            color: Colors.black.withOpacity(0.05),
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
                    const Icon(Icons.attach_file, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
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
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => _sendMessage(_controller.text),
              child: CircleAvatar(
                backgroundColor: _isLoading
                    ? Colors.grey[400]
                    : const Color(0xFF00C853),
                radius: 24,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.arrow_upward, color: Colors.white),
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

// ============= Chat Message Model =============
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
  });
}