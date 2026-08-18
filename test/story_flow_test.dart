import 'package:flutter_test/flutter_test.dart';
import 'package:make_sentence/main.dart';
import 'package:make_sentence/providers/app_provider.dart';
import 'package:make_sentence/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('user can create evaluate and save a story', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final appProvider = AppProvider(storageService: StorageService());
    await appProvider.init();
    await appProvider.startAsGuest(nickname: 'Tester');

    await tester.pumpWidget(MakeSentenceApp(appProvider: appProvider));
    await tester.pumpAndSettle();

    expect(find.text('Start Learning'), findsOneWidget);
    await tester.tap(find.byKey(const Key('startLearningButton')));
    await tester.pumpAndSettle();

    Future<void> addSentence(String text, {bool goBackToBuilder = true}) async {
      await tester.enterText(find.byKey(const Key('sentenceTextField')), text);
      await tester.tap(find.byKey(const Key('addToStoryButton')));
      await tester.pumpAndSettle();
      if (goBackToBuilder) {
        await tester.tap(find.byKey(const Key('addSentenceButton')));
        await tester.pumpAndSettle();
      }
    }

    await addSentence('The cat eats fish');
    await addSentence('I read a good book');
    await addSentence('We play with a happy dog', goBackToBuilder: false);

    await tester.enterText(find.byKey(const Key('storyTitleField')), 'My Practice Story');
    await tester.tap(find.byKey(const Key('evaluateStoryButton')));
    await tester.pumpAndSettle();

    expect(find.text('Story Result'), findsOneWidget);
    expect(find.text('My Practice Story'), findsWidgets);

    await tester.tap(find.byKey(const Key('saveStoryButton')));
    await tester.pumpAndSettle();

    expect(find.text('My Stories'), findsOneWidget);
    expect(find.text('My Practice Story'), findsOneWidget);
  });
}
