class SupportQuery {
  String id;
  String subject;
  String message;
  String userId;
  String userName;
  String userEmail;
  String status;
  String adminReply;
  DateTime? repliedAt;
  DateTime date;

  SupportQuery({
    required this.id,
    required this.subject,
    required this.message,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.date,
    this.adminReply = '',
    this.repliedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'subject': subject,
    'message': message,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'status': status,
    'adminReply': adminReply,
    'repliedAt': repliedAt?.millisecondsSinceEpoch,
    'date': date.toIso8601String(),
  };

  factory SupportQuery.fromMap(Map<String, dynamic> map) => SupportQuery(
    id: map['id'] as String? ?? '',
    subject: map['subject'] as String? ?? '',
    message: map['message'] as String? ?? '',
    userId: map['userId'] as String? ?? '',
    userName: map['userName'] as String? ?? '',
    userEmail: map['userEmail'] as String? ?? '',
    status: map['status'] as String? ?? 'open',
    adminReply: map['adminReply']?.toString() ?? '',
    repliedAt: _parseMillis(map['repliedAt']),
    date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
  );

  static DateTime? _parseMillis(dynamic v) {
    final ms = v is num ? v.toInt() : int.tryParse(v?.toString() ?? '');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}