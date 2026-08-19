import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../providers/story_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final stories = appProvider.stories.take(3).toList();
    final user = appProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MakeSentence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome${user == null ? '' : ', ${user.nickname}'}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep building short stories to grow your English confidence.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            key: const Key('startLearningButton'),
            onPressed: () {
              final currentUser = appProvider.user;
              if (currentUser == null) {
                Navigator.pushReplacementNamed(context, '/');
                return;
              }
              context.read<StoryProvider>().startNewStory(currentUser.id);
              Navigator.pushNamed(context, '/sentence-builder');
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Learning'),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: 'Stories created',
                          value: appProvider.storiesCreated.toString(),
                        ),
                      ),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Average score',
                          value: appProvider.averageScore.toStringAsFixed(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Stories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/my-stories'),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (stories.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No stories yet. Start learning!'),
              ),
            )
          else
            ...stories.map(
              (story) => Card(
                child: ListTile(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/story-detail',
                    arguments: story.id,
                  ),
                  title: Text(story.title),
                  subtitle: Text(DateFormat.yMMMd().format(story.createdAt)),
                  trailing: Text('${story.totalScore.toStringAsFixed(0)} pts'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
