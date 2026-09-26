class expense {
  int? id;
  double amount;
  String description;
  String source;
  String userid;
  String status;
  DateTime date;

  expense({
    this.id,
    required this.amount,
    required this.description,
    required this.source,
    required this.userid,
    this.status = 'pending',
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'source': source,
      'userid': userid,
      'status': status,
      'date': date.toIso8601String(),
    };
  }

  factory expense.fromMap(Map<String, dynamic> map) {
    return expense(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] ?? '',
      source: map['source'] ?? '',
      userid: map['userid'] ?? '',
      status: map['status'] ?? 'pending',
      date: DateTime.parse(map['date']),
    );
  }
}