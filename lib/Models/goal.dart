class Goal {
  String id;
  String title;
  String category;
  double target;
  double saved;
  double monthly;
  DateTime targetDate;
  String status;
  int milestone;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.target,
    required this.saved,
    required this.monthly,
    required this.targetDate,
    this.status = 'active',
    this.milestone = 0,
  });

  double get percent => target <= 0 ? 0 : (saved / target * 100).clamp(0, 100);
  double get remaining => (target - saved) < 0 ? 0 : target - saved;
  bool get isComplete => saved >= target;
  bool get isArchived => status == 'archived';

  int get monthsLeft {
    final now = DateTime.now();
    final m = (targetDate.year - now.year) * 12 + (targetDate.month - now.month);
    return m < 0 ? 0 : m;
  }


  bool get hasEstimate => !isComplete && monthly > 0;

  int get monthsToComplete {
    if (isComplete) return 0;
    if (monthly <= 0) return 0;
    return (remaining / monthly).ceil();
  }


  int get reachedMilestone {
    final p = percent;
    if (p >= 100) return 100;
    if (p >= 75) return 75;
    if (p >= 50) return 50;
    if (p >= 25) return 25;
    return 0;
  }

  bool milestoneReached(int mark) => percent >= mark;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'target': target,
      'saved': saved,
      'monthly': monthly,
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'milestone': milestone,
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
      status: (map['status'] as String?) ?? 'active',
      milestone: (map['milestone'] as num?)?.toInt() ?? 0,
    );
  }
}
