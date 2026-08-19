import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/story_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Color _scoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    }
    if (score >= 60) {
      return Colors.orange;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final story = context.watch<StoryProvider>().currentStory;
    if (story == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Story Result')),
        body: const Center(child: Text('No evaluated story found.')),
      );
    }

    final scoreColor = _scoreColor(story.totalScore);

    return Scaffold(
      appBar: AppBar(title: const Text('Story Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story.totalScore.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total story score',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...story.sentences.map(
            (sentence) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sentence.text,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _scoreColor(sentence.score).withAlpha(31),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            sentence.score.toStringAsFixed(0),
                            style: TextStyle(
                              color: _scoreColor(sentence.score),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Grammar errors',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    if (sentence.grammarErrors.isEmpty)
                      const Text('No grammar errors found.')
                    else
                      ...sentence.grammarErrors.map((error) => Text('• $error')),
                    const SizedBox(height: 12),
                    Text(
                      'Suggestions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    ...sentence.suggestions.map((suggestion) => Text('→ $suggestion')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('saveStoryButton'),
            onPressed: () async {
              await context.read<StoryProvider>().saveStory();
              if (!context.mounted) {
                return;
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-stories',
                (route) => route.settings.name == '/home' || route.isFirst,
              );
            },
            child: const Text('Save Story'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit Story'),
          ),
        ],
      ),
    );
  }
}
