import 'package:flutter/material.dart';
import 'app_colors.dart';

// Add Expense screen. Static design only.
class AddExpense extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddExpense();
  }
}

class _AddExpense extends State<AddExpense> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _amountBlock(),
              const SizedBox(height: 20),
              _aiPill(),
              const SizedBox(height: 22),
              _categorySection(),
              const SizedBox(height: 22),
              _label('Date'),
              const SizedBox(height: 8),
              _dateField(),
              const SizedBox(height: 18),
              _label('Description'),
              const SizedBox(height: 8),
              _descriptionField(),
              const SizedBox(height: 18),
              _label('Receipt Attachment'),
              const SizedBox(height: 8),
              _receiptCard(),
              const SizedBox(height: 16),
              _limitCard(),
              const SizedBox(height: 20),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: const Icon(Icons.arrow_back, size: 24, color: AppColors.ink),
        ),
        const Expanded(
          child: Text(
            'Add Expense',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: const Icon(Icons.close, size: 24, color: AppColors.ink),
        ),
      ],
    );
  }

  Widget _amountBlock() {
    return Column(
      children: [
        const Text(
          'EXPENSE AMOUNT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              '\$',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.green,
              ),
            ),
            SizedBox(width: 6),
            Text(
              '18.50',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _quickAdd('+\$5'),
            const SizedBox(width: 10),
            _quickAdd('+\$10'),
            const SizedBox(width: 10),
            _quickAdd('+\$20'),
          ],
        ),
      ],
    );
  }

  Widget _quickAdd(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.blue,
        ),
      ),
    );
  }

  Widget _aiPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.amberSoft,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.auto_awesome, size: 15, color: AppColors.amber),
            SizedBox(width: 6),
            Text(
              'AI Auto-Categorized: ',
              style: TextStyle(fontSize: 13, color: AppColors.ink),
            ),
            Text(
              'Food & Dining  ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.amber,
              ),
            ),
            Text(
              'Change',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Spacer(),
            Text(
              '8 Categories',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _catTile(Icons.lunch_dining, 'Food', selected: true),
            const SizedBox(width: 12),
            _catTile(Icons.directions_bus, 'Transport'),
            const SizedBox(width: 12),
            _catTile(Icons.school, 'Education'),
            const SizedBox(width: 12),
            _catTile(Icons.shopping_bag_outlined, 'Shopping'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _catTile(Icons.movie_outlined, 'Fun'),
            const SizedBox(width: 12),
            _catTile(Icons.receipt_long, 'Bills'),
            const SizedBox(width: 12),
            _catTile(Icons.savings, 'Savings'),
            const SizedBox(width: 12),
            _catTile(Icons.more_horiz, 'Misc'),
          ],
        ),
      ],
    );
  }

  Widget _catTile(IconData icon, String label, {bool selected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.track,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.greenSoft : AppColors.purpleSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? AppColors.green : AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.green : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
    );
  }

  Widget _dateField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: const [
          Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.green),
          SizedBox(width: 12),
          Text(
            'Today, Oct 24, 2024',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _descriptionField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Chipotle Burrito Bowl with friends',
              style: TextStyle(fontSize: 15, color: AppColors.ink),
            ),
          ),
          Icon(Icons.edit_note, size: 20, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _receiptCard() {
    return _DashedBorder(
      radius: 14,
      color: AppColors.muted.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.green),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Chipotle_Oct24.jpg',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI extracted total \$18.50 & tax automatically',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, size: 13, color: AppColors.green),
                      SizedBox(width: 5),
                      Text(
                        'Verified by PennyPal AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.delete_outline, size: 22, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _limitCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Within Food & Dining limit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '\$124.50 left of \$250.00 monthly cap',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 54,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 0.5,
                minHeight: 8,
                backgroundColor: AppColors.track,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense saved')),
          );
          Navigator.maybePop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.check, size: 20),
        label: const Text(
          'Save Expense',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// Draws a dashed rounded border around its child.
class _DashedBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;

  const _DashedBorder({
    required this.child,
    this.radius = 14,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(radius, color),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  final double radius;
  final Color color;

  _DashedPainter(this.radius, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const double dash = 6;
    const double gap = 4;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final double next = dist + dash;
        final double end = next < metric.length ? next : metric.length;
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
