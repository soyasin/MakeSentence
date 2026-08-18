class WordCard {
  const WordCard({
    required this.id,
    required this.word,
    required this.pos,
    required this.level,
    required this.example,
  });

  final String id;
  final String word;
  final String pos;
  final String level;
  final String example;

  factory WordCard.fromJson(Map<String, dynamic> json) {
    return WordCard(
      id: json['id'] as String,
      word: json['word'] as String,
      pos: json['pos'] as String,
      level: json['level'] as String,
      example: json['example'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'pos': pos,
      'level': level,
      'example': example,
    };
  }
}
