import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'package:techwiz7/Services/Firebase_Auth_Services.dart';
import 'app_colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _auth = AuthService();

  bool bio = false;
  bool rtAlerts = true;
  bool digest = true;
  bool milestones = false;
  int themeIdx = 0;

  String _name = '';
  String _email = '';
  String _role = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _auth.getUserProfile();
      if (!mounted) return;

      if (data == null) {
        setState(() => _loading = false);
        return;
      }

      final first = (data['FirstName'] ?? '').toString();
      final last = (data['LastName'] ?? '').toString();

      setState(() {
        _name = '$first $last'.trim();
        _email = (data['Email'] ?? '').toString();
        _role = (data['Role'] ?? 'User').toString();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load profile: $e')),
      );
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('You will need to log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
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
        title: Row(
          children: const [
            Icon(Icons.savings, color: AppColors.green),
            SizedBox(width: 8),
            Text(
              'PennyPal',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.ink),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile & Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            _profileCard(),
            const SizedBox(height: 24),
            _secLabel('PREFERENCES'),
            const SizedBox(height: 8),
            _setTile(
              Icons.currency_exchange,
              'Currency Preference',
              '\$ USD (United States Dollar)',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.muted,
              ),
            ),
            _setTile(
              Icons.calendar_today,
              'Budget Cycle',
              'Monthly (1st to 31st)',
              trailing: const Icon(Icons.tune, color: AppColors.muted),
            ),
            _setTile(
              Icons.fingerprint,
              'Biometric Login',
              'Face ID / Fingerprint toggle',
              trailing: Switch(
                value: bio,
                onChanged: (v) => setState(() => bio = v),
                activeColor: AppColors.green,
              ),
            ),
            const SizedBox(height: 24),
            _secLabel('NOTIFICATIONS'),
            const SizedBox(height: 8),
            _setTile(
              Icons.notifications_active,
              'Real-Time Spending Alerts',
              'Instant push after card expense',
              trailing: Switch(
                value: rtAlerts,
                onChanged: (v) => setState(() => rtAlerts = v),
                activeColor: AppColors.green,
              ),
            ),
            _setTile(
              Icons.email,
              'Daily Budget Digest',
              'Morning email summary',
              trailing: Switch(
                value: digest,
                onChanged: (v) => setState(() => digest = v),
                activeColor: AppColors.green,
              ),
            ),
            _setTile(
              Icons.emoji_events,
              'Goal Milestones & Badges',
              'Celebrate savings targets',
              trailing: Switch(
                value: milestones,
                onChanged: (v) => setState(() => milestones = v),
                activeColor: AppColors.green,
              ),
            ),
            const SizedBox(height: 24),
            _secLabel('APPEARANCE & SYSTEM'),
            const SizedBox(height: 8),
            _themeCard(),
            const SizedBox(height: 12),
            _syncCard(),
            const SizedBox(height: 30),
            _signOutButton(),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'PennyPal v2.4.1 (Build 412) • Student Edition',
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: PennyBottomNav(currentIndex: 4),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.track),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.fill,
                child: Text(
                  _initials(_name),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? 'Student' : _name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: AppColors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Verified Student • $_role',
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _rewardsRow(),
        ],
      ),
    );
  }

  Widget _rewardsRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.amberSoft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏅', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level 4 Hive Saver (1,240 Honey Pts)',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'Next reward unlocks at 1,500 Pts',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _themeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Mode',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _themeOpt(0, '☀️ Light'),
                _themeOpt(1, '🌙 Dark'),
                _themeOpt(2, '💻 System'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _syncCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_sync, color: AppColors.green),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Cache & Sync',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'Last synced just now',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Sync Now',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleSignOut,
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _secLabel(String t) {
    return Text(
      t,
      style: const TextStyle(
        color: AppColors.muted,
        fontWeight: FontWeight.w800,
        fontSize: 12,
        letterSpacing: 1,
      ),
    );
  }

  Widget _setTile(
      IconData ic,
      String t,
      String sub, {
        required Widget trailing,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(ic, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _themeOpt(int i, String lbl) {
    final on = themeIdx == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => themeIdx = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: on ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: on
                ? [
              BoxShadow(
                color: AppColors.track,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Center(
            child: Text(
              lbl,
              style: TextStyle(
                color: on ? AppColors.ink : AppColors.muted,
                fontWeight: on ? FontWeight.w800 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}