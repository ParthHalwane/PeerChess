import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Board Style & Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF81B64C),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: BoardThemeOption.values.map((theme) {
                final isSelected = settings.boardTheme == theme;
                return ListTile(
                  title: Text(theme.displayName),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? const Color(0xFF81B64C) : Colors.grey,
                  ),
                  onTap: () => notifier.updateBoardTheme(theme),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Audio & Haptics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF81B64C),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Move Sound Effects'),
                  subtitle: const Text('Play sound on piece moves and captures'),
                  value: settings.soundEnabled,
                  activeTrackColor: const Color(0xFF81B64C),
                  onChanged: (val) => notifier.toggleSound(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Haptic Vibration'),
                  subtitle: const Text('Tactile vibration on moves and check'),
                  value: settings.vibrationEnabled,
                  activeTrackColor: const Color(0xFF81B64C),
                  onChanged: (val) => notifier.toggleVibration(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Keep Screen Awake'),
                  subtitle: const Text('Prevent device sleep during chess match'),
                  value: settings.keepScreenAwake,
                  activeTrackColor: const Color(0xFF81B64C),
                  onChanged: (val) => notifier.toggleKeepScreenAwake(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
