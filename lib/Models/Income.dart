// Income model and in-memory store.
// Swap IncomeStore for SQLite / Firebase later. The method names
// (add, delete, all) are the same ones a repository would expose,
// so the UI will not need changes.

class Income {
  final String id;
  final double amount;
  final String source;
  final DateTime date;
  final String description;

  const Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    required this.description,
  });

  // Used later for SQLite insert or a Firebase document.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'source': source,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      source: map['source'] as String,
      date: DateTime.parse(map['date'] as String),
      description: (map['description'] ?? '') as String,
    );
  }

  @override
  String toString() => toMap().toString();
}

class IncomeStore {
  IncomeStore._();
  static final IncomeStore instance = IncomeStore._();

  final List<Income> _items = [];

  List<Income> get all => List.unmodifiable(_items);

  double get total =>
      _items.fold(0.0, (sum, item) => sum + item.amount);

  bool get isEmpty => _items.isEmpty;

  void add(Income income) {
    _items.insert(0, income); // newest first
    print('[INCOME ADDED] ${income.toMap()}');
    printAll();
  }

  void delete(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final removed = _items.removeAt(index);
    print('[INCOME DELETED] ${removed.toMap()}');
    printAll();
  }

  void printAll() {
    print('[INCOME LIST] ${_items.length} record(s), total: '
        '${total.toStringAsFixed(2)}');
    for (final item in _items) {
      print('  ${item.toMap()}');
    }
  }
}