# MakeSentence

MakeSentence is a Flutter MVP for building simple English sentences, combining them into short stories, and receiving rule-based feedback for learning practice.

## Project overview

The app supports guest onboarding, sentence building with word cards, story editing, evaluation, local persistence, progress summaries, and saved-story review.

## MVP features checklist

- [x] Guest onboarding with nickname entry
- [x] Home dashboard with recent stories and score summary
- [x] Sentence builder with seeded word cards and inline validation
- [x] Story editor with title editing, sentence reordering, editing, and deletion
- [x] Rule-based evaluation engine for sentence and story scoring
- [x] Story result screen with per-sentence feedback
- [x] Local persistence using `shared_preferences`
- [x] Saved stories list and story detail review screen
- [x] Settings for learner level and placeholder notifications toggle
- [x] Unit and widget flow tests for core behavior

## Project structure

```
lib/
  data/
  features/
  models/
  providers/
  services/
```

Feature folders:

- onboarding
- home
- sentence_builder
- story_editor
- result
- my_stories
- story_detail
- settings

## Run instructions

1. Install Flutter 3.x or newer.
2. From the project root, install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Test instructions

Run all tests from the project root:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

## Evaluation rules

- Sentences start at 100 points.
- Very short input scores 0.
- Simple spelling, S+V+O completeness, and tense-conflict heuristics reduce points.
- Longer complete sentences receive a bonus.
- Story score is the average of sentence scores.

## Known limitations

- Grammar evaluation is intentionally heuristic and not a full language parser.
- Notifications are a UI placeholder only.
- Data is stored locally on-device; there is no cloud sync.
- Word cards are seeded and not personalized yet.
