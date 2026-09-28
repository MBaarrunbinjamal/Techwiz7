class BudgetModel {
  int? id;
  String userId;
  String category;
  double limit;
  String month;
  String status;
  int synced;

  BudgetModel({
    this.id,
    required this.userId,
    required this.category,
    required this.limit,
    required this.month,
    this.status = 'active',
    this.synced = 0,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userId,
      'category': category,
      'budgetLimit': limit,
      'month': month,
      'status': status,
      'synced': synced,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      userId: map['userid'] ?? '',
      category: map['category'] ?? '',
      limit: (map['budgetLimit'] as num).toDouble(),
      month: map['month'] ?? '',
      status: map['status'] ?? 'active',
      synced: map['synced'] ?? 0,
    );
  }
}