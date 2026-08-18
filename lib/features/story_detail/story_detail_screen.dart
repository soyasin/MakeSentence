import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../providers/story_provider.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    final story = context.watch<AppProvider>().findStoryById(storyId);
    if (story == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Story Detail')),
        body: const Center(child: Text('Story not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${DateFormat.yMMMd().format(story.createdAt)}'),
                  Text('Total score: ${story.totalScore.toStringAsFixed(1)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...story.sentences.map(
            (sentence) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentence.text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Score: ${sentence.score.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    if (sentence.grammarErrors.isNotEmpty) ...[
                      const Text('Errors:'),
                      ...sentence.grammarErrors.map((error) => Text('• $error')),
                      const SizedBox(height: 8),
                    ],
                    const Text('Suggestions:'),
                    ...sentence.suggestions.map((suggestion) => Text('→ $suggestion')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<StoryProvider>().startNewStory(story.userId, topic: story.topic);
              Navigator.pushNamed(context, '/sentence-builder');
            },
            child: const Text('Practice Again'),
          ),
        ],
      ),
    );
  }
}
