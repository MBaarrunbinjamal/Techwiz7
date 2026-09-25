import 'package:flutter/material.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});
  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool bio = false;
  bool rtAlerts = true;
  bool digest = true;
  bool milestones = false;
  int themeIdx = 0;

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
            Text('PennyPal', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit, color: AppColors.ink), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile & Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 16),
            Container(
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
                      const CircleAvatar(radius: 30, backgroundColor: AppColors.fill),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alex Johnson', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)),
                            const SizedBox(height: 2),
                            const Text('alex.j@university.edu', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, color: AppColors.green, size: 14),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Verified Student • Sophomore',
                                      style: TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.w700),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.greenTint, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(color: AppColors.amberSoft, shape: BoxShape.circle),
                          child: const Center(child: Text('🏅', style: TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Level 4 Hive Saver (1,240 Honey Pts)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ink)),
                              Text('Next reward unlocks at 1,500 Pts', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.muted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _secLabel('PREFERENCES'),
            const SizedBox(height: 8),
            _setTile(
              Icons.currency_exchange,
              'Currency Preference',
              '\$ USD (United States Dollar)',
              trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
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
              trailing: Switch(value: bio, onChanged: (v) => setState(() => bio = v), activeColor: AppColors.green),
            ),
            const SizedBox(height: 24),
            _secLabel('NOTIFICATIONS'),
            const SizedBox(height: 8),
            _setTile(
              Icons.notifications_active,
              'Real-Time Spending Alerts',
              'Instant push after card expense',
              trailing: Switch(value: rtAlerts, onChanged: (v) => setState(() => rtAlerts = v), activeColor: AppColors.green),
            ),
            _setTile(
              Icons.email,
              'Daily Budget Digest',
              'Morning email summary',
              trailing: Switch(value: digest, onChanged: (v) => setState(() => digest = v), activeColor: AppColors.green),
            ),
            _setTile(
              Icons.emoji_events,
              'Goal Milestones & Badges',
              'Celebrate savings targets',
              trailing: Switch(value: milestones, onChanged: (v) => setState(() => milestones = v), activeColor: AppColors.green),
            ),
            const SizedBox(height: 24),
            _secLabel('APPEARANCE & SYSTEM'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.track),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(8)),
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
            ),
            const SizedBox(height: 12),
            Container(
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
                        Text('Offline Cache & Sync', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink)),
                        Text('Last synced just now', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Sync Now', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
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

  Widget _secLabel(String t) {
    return Text(
      t,
      style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
    );
  }

  Widget _setTile(IconData ic, String t, String sub, {required Widget trailing}) {
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
            decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(8)),
            child: Icon(ic, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
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
            boxShadow: on ? [BoxShadow(color: AppColors.track, blurRadius: 4, offset: const Offset(0, 2))] : [],
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
