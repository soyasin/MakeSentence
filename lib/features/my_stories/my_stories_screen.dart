import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class MyStoriesScreen extends StatelessWidget {
  const MyStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = context.watch<AppProvider>().stories;

    return Scaffold(
      appBar: AppBar(title: const Text('My Stories')),
      body: stories.isEmpty
          ? const Center(child: Text('No stories yet. Start learning!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Dismissible(
                  key: ValueKey(story.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    await context.read<AppProvider>().deleteStory(story.id);
                    return true;
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/story-detail',
                        arguments: story.id,
                      ),
                      title: Text(story.title),
                      subtitle: Text(
                        '${DateFormat.yMMMd().format(story.createdAt)} • ${story.sentences.length} sentences',
                      ),
                      trailing: Text('${story.totalScore.toStringAsFixed(0)} pts'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
