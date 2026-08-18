import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/learning_progress.dart';
import '../models/story.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  AppProvider({required this.storageService});

  final StorageService storageService;
  final Uuid _uuid = const Uuid();

  User? _user;
  List<Story> _stories = [];
  List<LearningProgress> _progress = [];
  bool _notificationsEnabled = true;

  User? get user => _user;
  List<Story> get stories => List.unmodifiable(_stories);
  List<LearningProgress> get progress => List.unmodifiable(_progress);
  bool get notificationsEnabled => _notificationsEnabled;
  bool get hasUser => _user != null;
  int get storiesCreated => _stories.length;
  double get averageScore {
    if (_stories.isEmpty) {
      return 0;
    }
    final total = _stories.fold<double>(0, (sum, story) => sum + story.totalScore);
    return total / _stories.length;
  }

  Future<void> init() async {
    _user = await storageService.loadUser();
    _stories = await storageService.loadStories();
    _progress = await storageService.loadProgress();
    _notificationsEnabled = await storageService.loadNotificationsEnabled();
    _stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _progress.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> startAsGuest({String? nickname}) async {
    final value = nickname?.trim();
    final resolvedNickname = (value == null || value.isEmpty) ? 'Guest Learner' : value;
    _user = User(
      id: _uuid.v4(),
      nickname: resolvedNickname,
      level: 'beginner',
      createdAt: DateTime.now(),
    );
    await storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await storageService.clearUser();
    notifyListeners();
  }

  Future<void> updateLevel(String level) async {
    final currentUser = _user;
    if (currentUser == null) {
      return;
    }
    _user = currentUser.copyWith(level: level);
    await storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await storageService.setNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> saveStory(Story story) async {
    final storedStory = story.copyWith(
      sentences: story.sentences.map((sentence) => sentence.copyWith()).toList(),
    );
    final index = _stories.indexWhere((item) => item.id == storedStory.id);
    final isNewStory = index < 0;
    if (index >= 0) {
      _stories[index] = storedStory;
    } else {
      _stories.insert(0, storedStory);
    }
    _stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await storageService.saveStory(storedStory);
    if (isNewStory) {
      await _updateProgressForStory(storedStory);
    }
    notifyListeners();
  }

  Future<void> deleteStory(String id) async {
    _stories.removeWhere((story) => story.id == id);
    await storageService.deleteStory(id);
    notifyListeners();
  }

  Story? findStoryById(String id) {
    try {
      return _stories.firstWhere((story) => story.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProgress(LearningProgress progress) async {
    final index = _progress.indexWhere((item) => item.id == progress.id);
    if (index >= 0) {
      _progress[index] = progress;
    } else {
      _progress.insert(0, progress);
    }
    _progress.sort((a, b) => b.date.compareTo(a.date));
    await storageService.saveProgress(progress);
    notifyListeners();
  }

  Future<void> _updateProgressForStory(Story story) async {
    final currentUser = _user;
    if (currentUser == null) {
      return;
    }

    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    final weakPoints = story.sentences
        .expand((sentence) => sentence.grammarErrors)
        .toSet()
        .toList();

    final existingIndex = _progress.indexWhere(
      (item) =>
          item.userId == currentUser.id &&
          item.date.year == normalizedDate.year &&
          item.date.month == normalizedDate.month &&
          item.date.day == normalizedDate.day,
    );

    if (existingIndex >= 0) {
      final existing = _progress[existingIndex];
      final newCount = existing.createdCount + 1;
      final newAverage = ((existing.avgScore * existing.createdCount) + story.totalScore) / newCount;
      final mergedWeakPoints = {...existing.weakPoints, ...weakPoints}.toList();
      final updated = existing.copyWith(
        createdCount: newCount,
        avgScore: newAverage,
        weakPoints: mergedWeakPoints,
      );
      await saveProgress(updated);
      return;
    }

    final progress = LearningProgress(
      id: _uuid.v4(),
      userId: currentUser.id,
      date: normalizedDate,
      createdCount: 1,
      avgScore: story.totalScore,
      weakPoints: weakPoints,
    );
    await saveProgress(progress);
  }
}
