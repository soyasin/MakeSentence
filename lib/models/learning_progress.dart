class LearningProgress {
  LearningProgress({
    required this.id,
    required this.userId,
    required this.date,
    required this.createdCount,
    required this.avgScore,
    required this.weakPoints,
  });

  final String id;
  final String userId;
  final DateTime date;
  int createdCount;
  double avgScore;
  List<String> weakPoints;

  LearningProgress copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? createdCount,
    double? avgScore,
    List<String>? weakPoints,
  }) {
    return LearningProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      createdCount: createdCount ?? this.createdCount,
      avgScore: avgScore ?? this.avgScore,
      weakPoints: weakPoints ?? List<String>.from(this.weakPoints),
    );
  }

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      createdCount: json['createdCount'] as int,
      avgScore: (json['avgScore'] as num).toDouble(),
      weakPoints: List<String>.from(json['weakPoints'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'createdCount': createdCount,
      'avgScore': avgScore,
      'weakPoints': weakPoints,
    };
  }
}
