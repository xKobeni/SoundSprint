class Question {
  final String mode;
  final String category;
  final String difficulty;
  final String? type; // 'sound', 'music', 'truefalse', 'vocabulary'
  final String? file;
  final int? clipStart;
  final int? clipEnd;
  final List<String>? options;
  final String? correctAnswer;
  final String? question; // for true/false and vocabulary
  final bool? answer; // for true/false

  Question({
    required this.mode,
    required this.category,
    required this.difficulty,
    this.type,
    this.file,
    this.clipStart,
    this.clipEnd,
    this.options,
    this.correctAnswer,
    this.question,
    this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      mode: json['mode'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      type: json['type'] as String?,
      file: json['file'] as String?,
      clipStart: json['clipStart'] as int?,
      clipEnd: json['clipEnd'] as int?,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correctAnswer'] as String?,
      question: json['question'] as String?,
      answer: json['answer'] as bool?,
    );
  }
} 