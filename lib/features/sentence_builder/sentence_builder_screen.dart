import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/word_cards.dart';
import '../../models/word_card.dart';
import '../../services/evaluation_service.dart';
import '../../providers/story_provider.dart';

class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({super.key});

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  final TextEditingController _controller = TextEditingController();
  final EvaluationService _evaluationService = EvaluationService();
  late final Map<String, List<WordCard>> _groupedCards;
  EvaluationResult? _result;

  @override
  void initState() {
    super.initState();
    _groupedCards = <String, List<WordCard>>{};
    for (final card in wordCards) {
      _groupedCards.putIfAbsent(card.pos, () => <WordCard>[]).add(card);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _appendWord(String word) {
    final text = _controller.text.trim();
    _controller.text = text.isEmpty ? word : '$text $word';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  void _validate() {
    setState(() {
      _result = _evaluationService.evaluateSentence(_controller.text);
    });
  }

  void _addToStory() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please build a sentence first.')),
      );
      return;
    }
    context.read<StoryProvider>().addSentenceFromText(text);
    setState(() {
      _controller.clear();
      _result = null;
    });
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, '/story-editor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Build a Sentence')),
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
                    'Pattern Guide',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('S + V + O (Subject + Verb + Object)'),
                  const SizedBox(height: 4),
                  Text(
                    'Example: The cat eats fish.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._groupedCards.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value
                        .map<Widget>(
                          (card) => ActionChip(
                            label: Text(card.word),
                            onPressed: () => _appendWord(card.word),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            key: const Key('sentenceTextField'),
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Your sentence',
              hintText: 'The cat eats fish',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('validateButton'),
                  onPressed: _validate,
                  child: const Text('Validate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  key: const Key('addToStoryButton'),
                  onPressed: _addToStory,
                  child: const Text('Add to Story'),
                ),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: ${_result!.score.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_result!.grammarErrors.isEmpty)
                      const Text('No major grammar issues found.')
                    else
                      ..._result!.grammarErrors.map(
                        (error) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $error'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    ..._result!.suggestions.map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('→ $suggestion'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
