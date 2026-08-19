import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/sentence.dart';
import '../models/story.dart';
import '../services/evaluation_service.dart';
import 'app_provider.dart';

class StoryProvider extends ChangeNotifier {
  StoryProvider({
    required AppProvider appProvider,
    required this.evaluationService,
  }) : _appProvider = appProvider;

  final EvaluationService evaluationService;
  final Uuid _uuid = const Uuid();
  AppProvider _appProvider;

  Story? _currentStory;
  List<Sentence> _sentences = [];
  bool _isEvaluated = false;

  Story? get currentStory => _currentStory;
  List<Sentence> get sentences => List.unmodifiable(_sentences);

  void updateAppProvider(AppProvider appProvider) {
    _appProvider = appProvider;
  }

  void startNewStory(
    String userId, {
    String title = 'Untitled Story',
    String topic = 'Free Topic',
  }) {
    _currentStory = Story(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      topic: topic,
      totalScore: 0,
      createdAt: DateTime.now(),
      sentences: [],
    );
    _sentences = [];
    _isEvaluated = false;
    notifyListeners();
  }

  void ensureCurrentStory() {
    final user = _appProvider.user;
    if (_currentStory == null && user != null) {
      startNewStory(user.id);
    }
  }

  void loadStory(Story story) {
    _currentStory = story.copyWith(
      sentences: story.sentences.map((sentence) => sentence.copyWith()).toList(),
    );
    _sentences = _currentStory!.sentences.map((sentence) => sentence.copyWith()).toList();
    _isEvaluated = _sentences.any(
      (sentence) => sentence.score > 0 || sentence.grammarErrors.isNotEmpty || sentence.suggestions.isNotEmpty,
    );
    notifyListeners();
  }

  void setTitle(String title) {
    ensureCurrentStory();
    if (_currentStory == null) {
      return;
    }
    _currentStory!.title = title.trim().isEmpty ? 'Untitled Story' : title.trim();
    notifyListeners();
  }

  void addSentenceFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    ensureCurrentStory();
    if (_currentStory == null) {
      return;
    }
    final sentence = Sentence(
      id: _uuid.v4(),
      storyId: _currentStory!.id,
      order: _sentences.length,
      text: trimmed,
      score: 0,
      grammarErrors: [],
      suggestions: [],
    );
    _sentences = [..._sentences, sentence];
    _syncStorySentences();
    _isEvaluated = false;
    notifyListeners();
  }

  void updateSentence(String sentenceId, String newText) {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final index = _sentences.indexWhere((sentence) => sentence.id == sentenceId);
    if (index < 0) {
      return;
    }
    _sentences[index].text = trimmed;
    _syncStorySentences();
    _isEvaluated = false;
    notifyListeners();
  }

  void removeSentence(String sentenceId) {
    _sentences.removeWhere((sentence) => sentence.id == sentenceId);
    _reindex();
    _syncStorySentences();
    _isEvaluated = false;
    notifyListeners();
  }

  void reorderSentences(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _sentences.removeAt(oldIndex);
    _sentences.insert(newIndex, item);
    _reindex();
    _syncStorySentences();
    _isEvaluated = false;
    notifyListeners();
  }

  Future<double> evaluateStory() async {
    ensureCurrentStory();
    if (_currentStory == null || _sentences.isEmpty) {
      return 0;
    }

    final results = _sentences
        .map((sentence) => evaluationService.evaluateSentence(sentence.text))
        .toList();

    for (var index = 0; index < _sentences.length; index++) {
      final result = results[index];
      _sentences[index]
        ..score = result.score
        ..grammarErrors = List<String>.from(result.grammarErrors)
        ..suggestions = List<String>.from(result.suggestions);
    }

    _currentStory!.totalScore = evaluationService.computeStoryScore(results);
    _syncStorySentences();
    _isEvaluated = true;
    notifyListeners();
    return _currentStory!.totalScore;
  }

  Future<Story?> saveStory() async {
    if (_currentStory == null || _sentences.isEmpty) {
      return null;
    }
    if (!_isEvaluated) {
      await evaluateStory();
    }
    await _appProvider.saveStory(_currentStory!);
    return _currentStory;
  }

  void clearCurrentStory() {
    _currentStory = null;
    _sentences = [];
    _isEvaluated = false;
    notifyListeners();
  }

  void _reindex() {
    for (var index = 0; index < _sentences.length; index++) {
      _sentences[index].order = index;
    }
  }

  void _syncStorySentences() {
    _currentStory?.sentences = _sentences.map((sentence) => sentence.copyWith()).toList();
  }
}
