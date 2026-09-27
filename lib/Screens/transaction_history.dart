import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz7/shared/penny_bottom_nav.dart';
import 'app_colors.dart';

import 'package:techwiz7/Database_helper/DatabaseHelper.dart';
import 'package:techwiz7/Models/TransactionModel.dart';
import 'package:techwiz7/Services/PrefsService.dart';

class TransactionHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TransactionHistory();
  }
}

class _TransactionHistory extends State<TransactionHistory> {
  final TextEditingController searchController = TextEditingController();

  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];

  String selectedTab = 'All';
  String selectedTime = 'This Month';
  String selectedSource = 'All';
  String selectedSort = 'Newest';

  bool isLoading = true;

  double totalIncome = 0;
  double totalExpense = 0;
  double netBalance = 0;

  @override
  void initState() {
    super.initState();

    loadTransactions();

    searchController.addListener(() {
      applyFilters();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = await PrefsService.instance.getUserId();

      if (userId == null || userId.isEmpty) {
        setState(() {
          allTransactions = [];
          filteredTransactions = [];
          isLoading = false;
        });
        return;
      }

      final transactions =
      await DatabaseHelper().getTransactions(userId);

      if (!mounted) return;

      setState(() {
        allTransactions = transactions;
        isLoading = false;
      });

      applyFilters();
    } catch (e) {
      print('TRANSACTION FETCH ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        allTransactions = [];
        filteredTransactions = [];
      });
    }
  }

  void applyFilters() {
    List<TransactionModel> result =
    List<TransactionModel>.from(allTransactions);

    final search = searchController.text.trim().toLowerCase();

    if (search.isNotEmpty) {
      result = result.where((transaction) {
        return transaction.description
            .toLowerCase()
            .contains(search) ||
            transaction.source
                .toLowerCase()
                .contains(search) ||
            transaction.type
                .toLowerCase()
                .contains(search) ||
            transaction.status
                .toLowerCase()
                .contains(search);
      }).toList();
    }

    if (selectedTab == 'Income') {
      result = result
          .where((transaction) => transaction.type == 'income')
          .toList();
    }

    if (selectedTab == 'Expense') {
      result = result
          .where((transaction) => transaction.type == 'expense')
          .toList();
    }

    final now = DateTime.now();

    if (selectedTime == 'This Month') {
      result = result.where((transaction) {
        return transaction.date.year == now.year &&
            transaction.date.month == now.month;
      }).toList();
    }

    if (selectedTime == 'Today') {
      result = result.where((transaction) {
        return transaction.date.year == now.year &&
            transaction.date.month == now.month &&
            transaction.date.day == now.day;
      }).toList();
    }

    if (selectedTime == 'This Week') {
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        Duration(days: now.weekday - 1),
      );

      final endOfWeek = startOfWeek.add(
        const Duration(days: 7),
      );

      result = result.where((transaction) {
        return !transaction.date.isBefore(startOfWeek) &&
            transaction.date.isBefore(endOfWeek);
      }).toList();
    }

    if (selectedSource != 'All') {
      result = result
          .where(
            (transaction) =>
        transaction.source == selectedSource,
      )
          .toList();
    }

    if (selectedSort == 'Newest') {
      result.sort(
            (a, b) => b.date.compareTo(a.date),
      );
    } else {
      result.sort(
            (a, b) => a.date.compareTo(b.date),
      );
    }

    double income = 0;
    double expense = 0;

    for (final transaction in result) {
      if (transaction.type == 'income') {
        income += transaction.amount;
      } else if (transaction.type == 'expense') {
        expense += transaction.amount;
      }
    }

    if (!mounted) return;

    setState(() {
      filteredTransactions = result;
      totalIncome = income;
      totalExpense = expense;
      netBalance = income - expense;
    });
  }

  List<String> get sources {
    final sourceList = allTransactions
        .map((transaction) => transaction.source)
        .where((source) => source.isNotEmpty)
        .toSet()
        .toList();

    sourceList.sort();

    return ['All', ...sourceList];
  }

  String formatAmount(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  String dateGroup(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(
      const Duration(days: 1),
    );

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return formatDate(date);
  }

  Map<String, List<TransactionModel>> groupTransactions() {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final transaction in filteredTransactions) {
      final key = dateGroup(transaction.date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(transaction);
    }

    return grouped;
  }

  void showTimeFilter() {
    final options = [
      'Today',
      'This Week',
      'This Month',
      'All Time',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Time Filter',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                ...options.map(
                      (option) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        option,
                        style: const TextStyle(
                          color: AppColors.ink,
                        ),
                      ),
                      trailing: selectedTime == option
                          ? const Icon(
                        Icons.check,
                        color: AppColors.green,
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          selectedTime = option;
                        });

                        Navigator.pop(context);
                        applyFilters();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSourceFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: sources.map(
                          (source) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            source,
                            style: const TextStyle(
                              color: AppColors.ink,
                            ),
                          ),
                          trailing: selectedSource == source
                              ? const Icon(
                            Icons.check,
                            color: AppColors.green,
                          )
                              : null,
                          onTap: () {
                            setState(() {
                              selectedSource = source;
                            });

                            Navigator.pop(context);
                            applyFilters();
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSortFilter() {
    final options = [
      'Newest',
      'Oldest',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort Transactions',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                ...options.map(
                      (option) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        option,
                        style: const TextStyle(
                          color: AppColors.ink,
                        ),
                      ),
                      trailing: selectedSort == option
                          ? const Icon(
                        Icons.check,
                        color: AppColors.green,
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          selectedSort = option;
                        });

                        Navigator.pop(context);
                        applyFilters();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        const Icon(
          Icons.savings,
          color: AppColors.green,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'PennyPal',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.tune,
          size: 22,
          color: AppColors.ink,
        ),
        const SizedBox(width: 16),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 24,
              color: AppColors.ink,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _titleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Track every penny, hive your wealth',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.amberSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: 15,
                color: AppColors.amber,
              ),
              SizedBox(width: 5),
              Text(
                'Level 4 Saver',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.track,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 20,
            color: AppColors.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                hintText:
                'Search transactions, merchants, notes...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                searchController.clear();
              },
              child: const Icon(
                Icons.close,
                size: 19,
                color: AppColors.muted,
              ),
            )
          else
            const Icon(
              Icons.mic_none,
              size: 20,
              color: AppColors.muted,
            ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _tab(
            'All',
            selected: selectedTab == 'All',
          ),
          _tab(
            'Income',
            selected: selectedTab == 'Income',
          ),
          _tab(
            'Expense',
            selected: selectedTab == 'Expense',
          ),
        ],
      ),
    );
  }

  Widget _tab(
      String label, {
        bool selected = false,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = label;
          });

          applyFilters();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.green
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            selectedTime,
            onTap: showTimeFilter,
          ),
          const SizedBox(width: 10),
          _filterChip(
            selectedSource == 'All'
                ? 'Category: All'
                : 'Category: $selectedSource',
            onTap: showSourceFilter,
          ),
          const SizedBox(width: 10),
          _filterChip(
            'Sort: $selectedSort',
            onTap: showSortFilter,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
      String label, {
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.track,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.track,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVITY SUMMARY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${filteredTransactions.length} Transactions',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              const Text(
                'NET FLOW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${netBalance >= 0 ? '+' : '-'}Rs. ${formatAmount(netBalance.abs())}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: netBalance >= 0
                      ? AppColors.green
                      : AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateHeader(
      String date,
      String items,
      ) {
    return Row(
      children: [
        Text(
          date,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const Spacer(),
        Text(
          items,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _txnRow(
      TransactionModel transaction,
      ) {
    final isIncome =
        transaction.type.toLowerCase() == 'income';

    final Color iconBg = isIncome
        ? AppColors.greenSoft
        : AppColors.purpleSoft;

    final Color iconColor = isIncome
        ? AppColors.green
        : AppColors.purple;

    final Color amountColor = isIncome
        ? AppColors.green
        : AppColors.ink;

    final IconData icon = isIncome
        ? Icons.payments_outlined
        : Icons.receipt_long_outlined;

    final String title =
    transaction.description.isNotEmpty
        ? transaction.description
        : transaction.source;

    final String sub =
        '${transaction.source}  •  ${formatTime(transaction.date)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.track,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        sub,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isIncome
                              ? AppColors.green
                              : AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.status ==
                            'synced'
                            ? AppColors.greenSoft
                            : AppColors.amberSoft,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Text(
                        transaction.status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w700,
                          color: transaction.status ==
                              'synced'
                              ? AppColors.green
                              : AppColors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}Rs. ${formatAmount(transaction.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.type,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionList() {
    if (filteredTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
        ),
        child: Center(
          child: Column(
            children: const [
              Icon(
                Icons.receipt_long_outlined,
                size: 55,
                color: AppColors.muted,
              ),
              SizedBox(height: 12),
              Text(
                'No transactions found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Try changing your search or filters',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = groupTransactions();

    return Column(
      children: grouped.entries.map(
            (entry) {
          double dayIncome = 0;
          double dayExpense = 0;

          for (final transaction in entry.value) {
            if (transaction.type == 'income') {
              dayIncome += transaction.amount;
            } else {
              dayExpense += transaction.amount;
            }
          }

          final dayNet =
              dayIncome - dayExpense;

          return Column(
            children: [
              const SizedBox(height: 18),
              _dateHeader(
                entry.key,
                '${entry.value.length} items  •  ${dayNet >= 0 ? '+' : '-'}Rs. ${formatAmount(dayNet.abs())}',
              ),
              const SizedBox(height: 10),
              ...entry.value.map(
                    (transaction) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: _txnRow(transaction),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  Widget _syncFooter() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.verified_outlined,
            size: 15,
            color: AppColors.muted,
          ),
          SizedBox(width: 6),
          Text(
            'All synced with linked student accounts',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
          ),
        )
            : RefreshIndicator(
          color: AppColors.green,
          onRefresh: loadTransactions,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 18),
                _titleRow(),
                const SizedBox(height: 16),
                _searchBar(),
                const SizedBox(height: 14),
                _tabs(),
                const SizedBox(height: 14),
                _filters(),
                const SizedBox(height: 16),
                _summaryCard(),
                _transactionList(),
                const SizedBox(height: 20),
                _syncFooter(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
      PennyBottomNav(currentIndex: 1),
    );
  }
}