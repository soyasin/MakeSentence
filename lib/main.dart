import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/my_stories/my_stories_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/result/result_screen.dart';
import 'features/sentence_builder/sentence_builder_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/story_detail/story_detail_screen.dart';
import 'features/story_editor/story_editor_screen.dart';
import 'providers/app_provider.dart';
import 'providers/story_provider.dart';
import 'services/evaluation_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider(storageService: StorageService());
  await appProvider.init();
  runApp(MakeSentenceApp(appProvider: appProvider));
}

class MakeSentenceApp extends StatelessWidget {
  const MakeSentenceApp({super.key, required this.appProvider});

  final AppProvider appProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: appProvider),
        ChangeNotifierProxyProvider<AppProvider, StoryProvider>(
          create: (_) => StoryProvider(
            appProvider: appProvider,
            evaluationService: EvaluationService(),
          ),
          update: (_, updatedAppProvider, storyProvider) {
            storyProvider?.updateAppProvider(updatedAppProvider);
            return storyProvider ??
                StoryProvider(
                  appProvider: updatedAppProvider,
                  evaluationService: EvaluationService(),
                );
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MakeSentence',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute<void>(builder: (_) => const RootScreen());
            case '/home':
              return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
            case '/sentence-builder':
              return MaterialPageRoute<void>(builder: (_) => const SentenceBuilderScreen());
            case '/story-editor':
              return MaterialPageRoute<void>(builder: (_) => const StoryEditorScreen());
            case '/result':
              return MaterialPageRoute<void>(builder: (_) => const ResultScreen());
            case '/my-stories':
              return MaterialPageRoute<void>(builder: (_) => const MyStoriesScreen());
            case '/story-detail':
              final storyId = settings.arguments as String?;
              return MaterialPageRoute<void>(
                builder: (_) => StoryDetailScreen(storyId: storyId ?? ''),
              );
            case '/settings':
              return MaterialPageRoute<void>(builder: (_) => const SettingsScreen());
            default:
              return MaterialPageRoute<void>(builder: (_) => const RootScreen());
          }
        },
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUser = context.watch<AppProvider>().hasUser;
    return hasUser ? const HomeScreen() : const OnboardingScreen();
  }
}
