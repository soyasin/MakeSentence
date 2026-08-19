import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_progress.dart';
import '../models/story.dart';
import '../models/user.dart';

class StorageService {
  static const String _storiesKey = 'stories';
  static const String _userKey = 'user';
  static const String _progressKey = 'progress';
  static const String _notificationsKey = 'notifications_enabled';

  Future<void> saveStory(Story story) async {
    final preferences = await SharedPreferences.getInstance();
    final stories = _loadStoriesFromPreferences(preferences);
    final index = stories.indexWhere((item) => item.id == story.id);
    if (index >= 0) {
      stories[index] = story;
    } else {
      stories.add(story);
    }
    final payload = jsonEncode(stories.map((item) => item.toJson()).toList());
    await preferences.setString(_storiesKey, payload);
  }

  Future<List<Story>> loadStories() async {
    final preferences = await SharedPreferences.getInstance();
    return _loadStoriesFromPreferences(preferences);
  }

  List<Story> _loadStoriesFromPreferences(SharedPreferences preferences) {
    final raw = preferences.getString(_storiesKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Story.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> deleteStory(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final stories = _loadStoriesFromPreferences(preferences);
    stories.removeWhere((story) => story.id == id);
    final payload = jsonEncode(stories.map((item) => item.toJson()).toList());
    await preferences.setString(_storiesKey, payload);
  }

  Future<void> saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> loadUser() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return User.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<void> clearUser() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userKey);
  }

  Future<void> saveProgress(LearningProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    final progressList = _loadProgressFromPreferences(preferences);
    final index = progressList.indexWhere((item) => item.id == progress.id);
    if (index >= 0) {
      progressList[index] = progress;
    } else {
      progressList.add(progress);
    }
    final payload = jsonEncode(progressList.map((item) => item.toJson()).toList());
    await preferences.setString(_progressKey, payload);
  }

  Future<List<LearningProgress>> loadProgress() async {
    final preferences = await SharedPreferences.getInstance();
    return _loadProgressFromPreferences(preferences);
  }

  List<LearningProgress> _loadProgressFromPreferences(SharedPreferences preferences) {
    final raw = preferences.getString(_progressKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => LearningProgress.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_notificationsKey, value);
  }

  Future<bool> loadNotificationsEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_notificationsKey) ?? true;
  }
}
