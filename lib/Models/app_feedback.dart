
class AppFeedback {
  String id;
  String name;
  String email;
  int rating;
  String comments;
  String userId;
  DateTime date;

  AppFeedback({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.comments,
    required this.userId,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'rating': rating,
        'comments': comments,
        'userId': userId,
        'date': date.toIso8601String(),
      };

  factory AppFeedback.fromMap(Map<String, dynamic> map) => AppFeedback(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        rating: (map['rating'] as num?)?.toInt() ?? 0,
        comments: map['comments'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        date: DateTime.parse(map['date'] as String),
      );
}
