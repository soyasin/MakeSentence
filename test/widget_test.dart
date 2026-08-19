import 'package:flutter_test/flutter_test.dart';
import 'package:make_sentence/main.dart';
import 'package:make_sentence/providers/app_provider.dart';
import 'package:make_sentence/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app launches to onboarding without saved user', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final appProvider = AppProvider(storageService: StorageService());
    await appProvider.init();

    await tester.pumpWidget(MakeSentenceApp(appProvider: appProvider));
    await tester.pumpAndSettle();

    expect(find.text('MakeSentence'), findsOneWidget);
    expect(find.text('Start as Guest'), findsOneWidget);
  });
}
