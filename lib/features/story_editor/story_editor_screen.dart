import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/story_provider.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({super.key});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  Future<void> _editSentence(BuildContext context, String id, String currentText) async {
    final controller = TextEditingController(text: currentText);
    final updatedText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit sentence'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Sentence'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || updatedText == null || updatedText.isEmpty) {
      return;
    }
    context.read<StoryProvider>().updateSentence(id, updatedText);
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final currentStory = storyProvider.currentStory;
    final sentences = storyProvider.sentences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () async {
              if (sentences.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add at least 1 sentence before saving.')),
                );
                return;
              }
              await context.read<StoryProvider>().saveStory();
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story saved.')),
              );
            },
          ),
        ],
      ),
      body: currentStory == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No story started yet.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/sentence-builder'),
                      child: const Text('Build a sentence'),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextFormField(
                      key: const Key('storyTitleField'),
                      initialValue: currentStory.title,
                      onChanged: (value) => context.read<StoryProvider>().setTitle(value),
                      decoration: const InputDecoration(
                        labelText: 'Story title',
                        hintText: 'My first story',
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                if (sentences.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Add sentences to start your story.'),
                        ),
                      ),
                    ),
                  )
                else
                  SliverReorderableList(
                    itemCount: sentences.length,
                    onReorder: (oldIndex, newIndex) {
                      context.read<StoryProvider>().reorderSentences(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final sentence = sentences[index];
                      return ReorderableDragStartListener(
                        key: ValueKey(sentence.id),
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${sentence.order + 1}')),
                              title: Text(sentence.text),
                              subtitle: sentence.score > 0
                                  ? Text('Score: ${sentence.score.toStringAsFixed(0)}')
                                  : null,
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _editSentence(
                                      context,
                                      sentence.id,
                                      sentence.text,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => context
                                        .read<StoryProvider>()
                                        .removeSentence(sentence.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: OutlinedButton.icon(
                      key: const Key('addSentenceButton'),
                      onPressed: () => Navigator.pushNamed(context, '/sentence-builder'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Sentence'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: ElevatedButton(
                      key: const Key('evaluateStoryButton'),
                      onPressed: () async {
                        if (sentences.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add at least 1 sentence first.')),
                          );
                          return;
                        }
                        await context.read<StoryProvider>().evaluateStory();
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pushNamed(context, '/result');
                      },
                      child: const Text('Evaluate Story'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
