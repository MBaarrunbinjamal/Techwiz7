class TransactionModel {
  int? id;
  String? firebaseId;
  String userId;
  String type;
  double amount;
  String description;
  String source;
  String status;
  DateTime date;

  TransactionModel({
    this.id,
    this.firebaseId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.source,
    this.status = 'pending',
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'userid': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'source': source,
      'status': status,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      firebaseId: map['firebaseId'],
      userId: map['userid'] ?? '',
      type: map['type'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] ?? '',
      source: map['source'] ?? '',
      status: map['status'] ?? 'pending',
      date: DateTime.parse(map['date']),
    );
  }
}