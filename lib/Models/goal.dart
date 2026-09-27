class Goal {
  String id;
  String title;
  String category;
  double target;
  double saved;
  double monthly;
  DateTime targetDate;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.target,
    required this.saved,
    required this.monthly,
    required this.targetDate,
  });

  double get percent => target <= 0 ? 0 : (saved / target * 100).clamp(0, 100);
  double get remaining => (target - saved) < 0 ? 0 : target - saved;
  bool get isComplete => saved >= target;

  // Calendar months from now until the target date.
  int get monthsLeft {
    final now = DateTime.now();
    final m = (targetDate.year - now.year) * 12 + (targetDate.month - now.month);
    return m < 0 ? 0 : m;
  }

  // FR-35 estimated completion time.
  // Months needed at the current monthly contribution.
  // Returns 0 when the goal is done or when no monthly amount is set.
  // hasEstimate tells the UI whether a real number exists.
  bool get hasEstimate => !isComplete && monthly > 0;

  int get monthsToComplete {
    if (isComplete) return 0;
    if (monthly <= 0) return 0;
    return (remaining / monthly).ceil();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'target': target,
      'saved': saved,
      'monthly': monthly,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      target: (map['target'] as num?)?.toDouble() ?? 0,
      saved: (map['saved'] as num?)?.toDouble() ?? 0,
      monthly: (map['monthly'] as num?)?.toDouble() ?? 0,
      targetDate: DateTime.parse(map['targetDate']),
    );
  }
}