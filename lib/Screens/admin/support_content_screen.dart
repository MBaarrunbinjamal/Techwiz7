import 'package:flutter/material.dart';
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
  int tabIndex = 0;
  String filter = 'All';
  bool module3Active = true;
  bool module4Active = true;
  bool moduleDraftActive = false;

  final List<Map<String, dynamic>> queries = [
    {
      'name': 'Sarah Jenkins',
      'id': '#1043',
      'time': '25m ago',
      'status': 'In Review',
      'urgent': true,
      'title': 'Receipt scanner failed to recognize dining hall invoice',
      'description': '"The camera scanned the receipt but the total showed \$0.00 instead of \$14.50. I tried re-uploading twice under bright lighting with no change..."',
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
    {
      'name': 'Ayesha Khan',
      'id': '#1039',
      'time': '3h ago',
      'status': 'In Review',
      'urgent': true,
      'title': 'Cannot upload bank statement for verification',
      'description': '',
      'detailed': false,
    },
    {
      'name': 'Daniel Park',
      'id': '#1035',
      'time': '1d ago',
      'status': 'Resolved',
      'urgent': false,
      'title': 'App crashes on savings goal creation',
      'description': '',
      'detailed': false,
    },
  ];

  List<Map<String, dynamic>> get filteredQueries {
    if (filter == 'Urgent') return queries.where((q) => q['urgent'] == true).toList();
    if (filter == 'General') return queries.where((q) => q['urgent'] == false).toList();
    if (filter == 'Resolved') return queries.where((q) => q['status'] == 'Resolved').toList();
    return queries;
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
              ...filteredQueries.map((q) => q['detailed'] == true ? _buildSupportTicketCard(q) : _buildSimpleTicketCard(q)),
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
          Expanded(child: _buildTabButton('Support Queries', 0, Icons.support_agent, '14')),
          Expanded(child: _buildTabButton('Learning Content', 1, Icons.menu_book, '28')),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon, String count) {
    final isActive = tabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          tabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey),
              ),
            ),
            const SizedBox(width: 4),
            Text(count, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
          _buildFilterChip('Urgent', 'Urgent', false, const Color(0xFFFFEBEE), const Color(0xFFC62828)),
          const SizedBox(width: 8),
          _buildFilterChip('General', 'General', false),
          const SizedBox(width: 8),
          _buildFilterChip('Resolved', 'Resolved', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isFirst, [Color? bgColor, Color? textColor]) {
    final isActive = filter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          filter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1B5E20) : (bgColor ?? Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? const Color(0xFF1B5E20) : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : (textColor ?? Theme.of(context).textTheme.bodyLarge?.color),
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
                child: Text(q['name'][0], style: const TextStyle(color: Color(0xFFEF6C00), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(q['id'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                child: Text(q['status'], style: const TextStyle(fontSize: 10, color: Color(0xFFEF6C00), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(q['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(q['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(q['description'], style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 12),
          const Text('QUICK MACRO TEMPLATES', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMacroChip('Clear Cache Guide'),
              _buildMacroChip('Manual Entry Steps'),
              _buildMacroChip('Bug Logged'),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type admin reply to student...',
              hintStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Reassign', style: TextStyle(fontSize: 12)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Response sent & ticket resolved')),
                  );
                },
                icon: const Icon(Icons.send, size: 14),
                label: const Text('Send Response & Resolve', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: const TextStyle(fontSize: 10)),
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
            child: Text(q['name'][0], style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(q['name'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Text(q['id'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                Text(q['title'], style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
            child: Text(q['status'], style: const TextStyle(fontSize: 10, color: Color(0xFFEF6C00), fontWeight: FontWeight.bold)),
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
                  Text('Financial Literacy Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Curriculum & readership metrics', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add New', style: TextStyle(fontSize: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildModuleCard(
          'MODULE 03 • 4 MIN READ',
          'Needs vs Wants: The 24-Hour Rule',
          '4,210 Reads',
          '89% Completion Rate',
          true,
          module3Active,
              (v) => setState(() => module3Active = v),
        ),
        const SizedBox(height: 12),
        _buildModuleCard(
          'MODULE 04 • 6 MIN READ',
          'Credit Scores Decoded Before Graduation',
          'Active & Published',
          '',
          false,
          module4Active,
              (v) => setState(() => module4Active = v),
        ),
        const SizedBox(height: 12),
        _buildDraftModuleCard(
          'DRAFT • UNPUBLISHED',
          'Understanding Student Loan Forgiveness',
          moduleDraftActive,
              (v) => setState(() => moduleDraftActive = v),
        ),
      ],
    );
  }

  Widget _buildModuleCard(String module, String title, String metric1, String metric2, bool hasMetrics, bool isActive, Function(bool) onToggle) {
    return Container(
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
              Text(module, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Switch(value: isActive, onChanged: onToggle, activeColor: const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          if (hasMetrics) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 14, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      Text(metric1, style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      Text(metric2, style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: const [
                    Icon(Icons.copy, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Duplicate', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleted')),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete, size: 14, color: Color(0xFFC62828)),
                    SizedBox(width: 4),
                    Text('Delete', style: TextStyle(fontSize: 10, color: Color(0xFFC62828))),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Edit Content', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraftModuleCard(String module, String title, bool isActive, Function(bool) onToggle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(module, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Switch(value: isActive, onChanged: onToggle, activeColor: const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Last modified 2 days ago', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Edit Content', style: TextStyle(fontSize: 10)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    moduleDraftActive = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Publish Now', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}