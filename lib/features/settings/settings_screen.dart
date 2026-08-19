import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final level = appProvider.user?.level ?? 'beginner';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Language level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: level,
            decoration: const InputDecoration(labelText: 'Select level'),
            items: const [
              DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
              DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
              DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<AppProvider>().updateLevel(value);
              }
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Placeholder toggle for future reminders'),
            value: appProvider.notificationsEnabled,
            onChanged: (value) => context.read<AppProvider>().setNotificationsEnabled(value),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'MakeSentence helps learners build short English stories using simple word cards and rule-based feedback.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
