class Sentence {
  Sentence({
    required this.id,
    required this.storyId,
    required this.order,
    required this.text,
    required this.score,
    required this.grammarErrors,
    required this.suggestions,
  });

  final String id;
  final String storyId;
  int order;
  String text;
  double score;
  List<String> grammarErrors;
  List<String> suggestions;

  Sentence copyWith({
    String? id,
    String? storyId,
    int? order,
    String? text,
    double? score,
    List<String>? grammarErrors,
    List<String>? suggestions,
  }) {
    return Sentence(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      order: order ?? this.order,
      text: text ?? this.text,
      score: score ?? this.score,
      grammarErrors: grammarErrors ?? List<String>.from(this.grammarErrors),
      suggestions: suggestions ?? List<String>.from(this.suggestions),
    );
  }

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      order: json['order'] as int,
      text: json['text'] as String,
      score: (json['score'] as num).toDouble(),
      grammarErrors: List<String>.from(json['grammarErrors'] as List<dynamic>),
      suggestions: List<String>.from(json['suggestions'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'order': order,
      'text': text,
      'score': score,
      'grammarErrors': grammarErrors,
      'suggestions': suggestions,
    };
  }
}
