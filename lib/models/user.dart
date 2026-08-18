class User {
  const User({
    required this.id,
    required this.nickname,
    required this.level,
    required this.createdAt,
  });

  final String id;
  final String nickname;
  final String level;
  final DateTime createdAt;

  User copyWith({
    String? id,
    String? nickname,
    String? level,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      level: json['level'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
