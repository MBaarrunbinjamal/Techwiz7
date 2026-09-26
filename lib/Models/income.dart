class Income {
  int? id;
  double amount;
  String description;
  String source;
  String userid;
  String status;
  DateTime date;

  Income({
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

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
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