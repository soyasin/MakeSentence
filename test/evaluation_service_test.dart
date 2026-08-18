import 'package:flutter_test/flutter_test.dart';
import 'package:make_sentence/services/evaluation_service.dart';

void main() {
  late EvaluationService service;

  setUp(() {
    service = EvaluationService();
  });

  test('empty string returns zero score', () {
    final result = service.evaluateSentence('');

    expect(result.score, 0);
    expect(result.grammarErrors, contains('Sentence is too short'));
  });

  test('short sentence gets low score with errors', () {
    final result = service.evaluateSentence('Cat');

    expect(result.score, lessThan(100));
    expect(
      result.grammarErrors,
      contains('Sentence may be incomplete (missing subject, verb, or object)'),
    );
  });

  test('good sentence gets high score', () {
    final result = service.evaluateSentence('The cat eats fish');

    expect(result.score, greaterThanOrEqualTo(90));
    expect(result.grammarErrors, isEmpty);
  });

  test('sentence with potential issues reports feedback', () {
    final result = service.evaluateSentence('Yesterday I go sch');

    expect(result.score, lessThan(95));
    expect(result.grammarErrors, contains('Possible spelling error'));
    expect(result.grammarErrors, contains('Check tense consistency'));
  });

  test('computeStoryScore averages sentence scores', () {
    const results = [
      EvaluationResult(score: 80, grammarErrors: [], suggestions: []),
      EvaluationResult(score: 100, grammarErrors: [], suggestions: []),
    ];

    final score = service.computeStoryScore(results);

    expect(score, 90);
  });
}
