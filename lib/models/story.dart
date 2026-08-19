import 'sentence.dart';

class Story {
  Story({
    required this.id,
    required this.userId,
    required this.title,
    required this.topic,
    required this.totalScore,
    required this.createdAt,
    required this.sentences,
  });

  final String id;
  final String userId;
  String title;
  String topic;
  double totalScore;
  final DateTime createdAt;
  List<Sentence> sentences;

  Story copyWith({
    String? id,
    String? userId,
    String? title,
    String? topic,
    double? totalScore,
    DateTime? createdAt,
    List<Sentence>? sentences,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      totalScore: totalScore ?? this.totalScore,
      createdAt: createdAt ?? this.createdAt,
      sentences: sentences ?? this.sentences.map((sentence) => sentence.copyWith()).toList(),
    );
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      totalScore: (json['totalScore'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentences: (json['sentences'] as List<dynamic>)
          .map((item) => Sentence.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'topic': topic,
      'totalScore': totalScore,
      'createdAt': createdAt.toIso8601String(),
      'sentences': sentences.map((sentence) => sentence.toJson()).toList(),
    };
  }
}
