class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type; // 'score', 'streak', 'games', 'accuracy', 'category', 'difficulty'
  final int target;
  final int currentProgress;
  final bool isCompleted;
  final DateTime date;
  final String? reward;
  final int? rewardAmount;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.currentProgress = 0,
    this.isCompleted = false,
    required this.date,
    this.reward,
    this.rewardAmount,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      target: json['target'] as int,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
      reward: json['reward'] as String?,
      rewardAmount: json['rewardAmount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target': target,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'reward': reward,
      'rewardAmount': rewardAmount,
    };
  }

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? target,
    int? currentProgress,
    bool? isCompleted,
    DateTime? date,
    String? reward,
    int? rewardAmount,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      reward: reward ?? this.reward,
      rewardAmount: rewardAmount ?? this.rewardAmount,
    );
  }
} 