class User {
  final String name;
  final int age;
  final DateTime createdAt;

  User({
    required this.name,
    required this.age,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  User copyWith({String? name, int? age, DateTime? createdAt}) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 