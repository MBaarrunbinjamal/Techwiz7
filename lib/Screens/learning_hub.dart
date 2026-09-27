import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> _content = [];
  bool _isLoading = true;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    // Internet check
    final connectivity = await Connectivity().checkConnectivity();
    final hasNet = !connectivity.contains(ConnectivityResult.none);
    if (!mounted) return;
    setState(() => _hasInternet = hasNet);

    if (!hasNet) {
      setState(() => _isLoading = false);
      return;
    }
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
    });

    // Recheck internet before fetching
    final connectivity = await Connectivity().checkConnectivity();
    final hasNet = !connectivity.contains(ConnectivityResult.none);
    if (!hasNet) {
      if (!mounted) return;
      setState(() {
        _hasInternet = false;
        _isLoading = false;
      });
      return;
    }

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
              if (item['isActive'] != false) {
                item['_key'] = key;
                loaded.add(item);
              }
            }
          });
        } else if (raw is List) {
          for (int i = 0; i < raw.length; i++) {
            final v = raw[i];
            if (v is Map) {
              final item = Map<String, dynamic>.from(v);
              if (item['isActive'] != false) {
                item['_key'] = i.toString();
                loaded.add(item);
              }
            }
          }
        }
      }

      loaded.sort((a, b) {
        final ta = (a['publishedAt'] ?? 0) as num;
        final tb = (b['publishedAt'] ?? 0) as num;
        return tb.toInt().compareTo(ta.toInt());
      });

      if (!mounted) return;
      setState(() {
        _content = loaded;
        _isLoading = false;
        _hasInternet = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasInternet = false;
      });
    }
  }

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
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _loadContent),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const PennyBottomNav(currentIndex: 3),
    );
  }

  Widget _buildBody() {
    // ❌ Internet nahi hai → red error
    if (!_hasInternet) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off,
                    color: Color(0xFFC62828), size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                "Can't load content",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC62828),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Check your internet connection and try again.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initLoad,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "PENNYPAL ACADEMY",
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Latest Lessons",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${_content.length} available",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            if (_content.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.menu_book_outlined,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text("No lessons yet",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("Admin will publish content soon",
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              )
            else
              ..._content.map((c) => _buildLessonCard(c)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> c) {
    final title = (c['title'] ?? 'Untitled').toString();
    final desc = (c['description'] ?? '').toString();
    final tag = (c['tag'] ?? 'General').toString();
    final readTime = (c['readTime'] ?? '3 min read').toString();
    final img = (c['coverImage'] ?? '').toString();
    final content = (c['content'] ?? '').toString();
    final publishedAt = c['publishedAt'] ?? 0;

    Color tagBg = const Color(0xFFE8F5E9);
    Color tagFg = const Color(0xFF2E7D32);
    if (tag.toLowerCase().contains('beginner')) {
      tagBg = const Color(0xFFE3F2FD);
      tagFg = const Color(0xFF1565C0);
    } else if (tag.toLowerCase().contains('essential')) {
      tagBg = const Color(0xFFFFEBEE);
      tagFg = const Color(0xFFC62828);
    } else if (tag.toLowerCase().contains('intermediate')) {
      tagBg = const Color(0xFFF3E5F5);
      tagFg = const Color(0xFF6A1B9A);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _LearningDetailScreen(
              title: title,
              content: content,
              description: desc,
              coverImage: img,
              tag: tag,
              readTime: readTime,
              publishedAt: publishedAt,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (img.isNotEmpty)
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: img,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 160,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          tag,
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: tagFg),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(readTime,
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(desc,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(publishedAt),
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.grey)),
                      Text("Read →",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt =
      DateTime.fromMillisecondsSinceEpoch((ts as num).toInt());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ============ DETAIL SCREEN ============
class _LearningDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String description;
  final String coverImage;
  final String tag;
  final String readTime;
  final dynamic publishedAt;

  const _LearningDetailScreen({
    required this.title,
    required this.content,
    required this.description,
    required this.coverImage,
    required this.tag,
    required this.readTime,
    required this.publishedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Lesson',
            style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coverImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: coverImage,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: Colors.grey[100],
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(tag,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32))),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(readTime,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            if (description.isNotEmpty) ...[
              Text(description,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                      height: 1.5)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
            ],
            Text(
              content.isNotEmpty ? content : 'Content coming soon...',
              style: GoogleFonts.poppins(
                  fontSize: 15, height: 1.7, color: Colors.black87),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}