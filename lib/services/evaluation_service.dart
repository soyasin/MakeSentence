class EvaluationResult {
  const EvaluationResult({
    required this.score,
    required this.grammarErrors,
    required this.suggestions,
  });

  final double score;
  final List<String> grammarErrors;
  final List<String> suggestions;
}

class EvaluationService {
  static const Set<String> _vowels = {'a', 'e', 'i', 'o', 'u'};
  static const Set<String> _verbs = {
    'am',
    'is',
    'are',
    'was',
    'were',
    'be',
    'go',
    'goes',
    'run',
    'runs',
    'eat',
    'eats',
    'drink',
    'drinks',
    'read',
    'reads',
    'write',
    'writes',
    'play',
    'plays',
    'see',
    'sees',
    'like',
    'likes',
    'have',
    'has',
    'make',
    'makes',
    'take',
    'takes',
    'know',
    'knows',
  };
  static const Set<String> _presentMarkers = {
    'go',
    'goes',
    'run',
    'runs',
    'eat',
    'eats',
    'drink',
    'drinks',
    'play',
    'plays',
    'read',
    'reads',
    'write',
    'writes',
    'see',
    'sees',
    'like',
    'likes',
    'have',
    'has',
    'make',
    'makes',
    'take',
    'takes',
    'know',
    'knows',
    'is',
    'are',
  };
  static const Set<String> _pastContextMarkers = {
    'yesterday',
    'ago',
    'last',
    'before',
  };

  EvaluationResult evaluateSentence(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length < 3) {
      return const EvaluationResult(
        score: 0,
        grammarErrors: ['Sentence is too short'],
        suggestions: ['Try using a subject + verb + object structure (S+V+O)'],
      );
    }

    final rawWords = trimmed.split(RegExp(r'\s+'));
    final words = rawWords
        .map((word) => word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''))
        .where((word) => word.isNotEmpty)
        .toList();

    double score = 100;
    final errors = <String>[];
    final suggestions = <String>[];

    for (final word in words) {
      if (word.length > 1 && !_containsVowel(word)) {
        score -= 5;
        if (!errors.contains('Possible spelling error')) {
          errors.add('Possible spelling error');
        }
      }
    }

    final hasVerb = words.skip(1).any(_looksLikeVerb);
    final incompletePenalty = words.length < 3 ? 35 : (!hasVerb ? 10 : 0);
    if (incompletePenalty > 0) {
      score -= incompletePenalty;
      if (!errors.contains('Sentence may be incomplete (missing subject, verb, or object)')) {
        errors.add('Sentence may be incomplete (missing subject, verb, or object)');
      }
    }

    if (_hasTenseConflict(words)) {
      score -= 10;
      if (!errors.contains('Check tense consistency')) {
        errors.add('Check tense consistency');
      }
    }

    if (words.length == 3) {
      score += 2;
    } else if (words.length >= 4 && words.length <= 6) {
      score += 5;
    } else if (words.length >= 7) {
      score += 10;
    }

    final displayScore = score.clamp(0, 100).toDouble();

    if (displayScore < 70) {
      suggestions.add('Try using a subject + verb + object structure (S+V+O)');
    }
    if (displayScore < 50) {
      suggestions.add('Consider rewriting this sentence more clearly');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Nice work! Try adding more detail to your story.');
    }

    return EvaluationResult(
      score: displayScore,
      grammarErrors: errors,
      suggestions: suggestions,
    );
  }

  double computeStoryScore(List<EvaluationResult> results) {
    if (results.isEmpty) {
      return 0;
    }
    final total = results.fold<double>(0, (sum, result) => sum + result.score);
    return total / results.length;
  }

  bool _containsVowel(String word) {
    return word.split('').any(_vowels.contains);
  }

  bool _looksLikeVerb(String word) {
    return _verbs.contains(word) || word.endsWith('ed') || word.endsWith('ing');
  }

  bool _hasTenseConflict(List<String> words) {
    final hasPastContext = words.any(_pastContextMarkers.contains);
    final hasPresentVerb = words.any(_presentMarkers.contains);
    return hasPastContext && hasPresentVerb;
  }
}
