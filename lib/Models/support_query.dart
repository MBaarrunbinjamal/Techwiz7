// One support message lives under support/{uid}/{queryId}.
// The logged in user is stored on the record so the admin knows who sent it.
class SupportQuery {
  String id;
  String subject;
  String message;
  String userId; // uid of the signed in student
  String userName; // full name read from the users node
  String userEmail; // email the admin replies to
  String status; // stays 'open' until an admin replies
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
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'subject': subject,
        'message': message,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'status': status,
        'date': date.toIso8601String(),
      };

  factory SupportQuery.fromMap(Map<String, dynamic> map) => SupportQuery(
        id: map['id'] as String,
        subject: map['subject'] as String? ?? '',
        message: map['message'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        userName: map['userName'] as String? ?? '',
        userEmail: map['userEmail'] as String? ?? '',
        status: map['status'] as String? ?? 'open',
        date: DateTime.parse(map['date'] as String),
      );
}
