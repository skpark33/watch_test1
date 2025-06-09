import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch/features/clock/domain/entities/clock_settings.dart';
import 'package:watch/features/settings/domain/usecases/get_settings.dart';
import 'package:watch/features/settings/domain/usecases/save_settings.dart';

class SettingsNotifier extends StateNotifier<ClockSettings> {
  final GetSettings _getSettings;
  final SaveSettings _saveSettings;

  SettingsNotifier(this._getSettings, this._saveSettings) : super(const ClockSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = await _getSettings();
  }

  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    final newSettings = state.copyWith(themeMode: newThemeMode);
    state = newSettings;
    await _saveSettings(newSettings);
  }

  Future<void> updateTimeFormat(TimeFormat newTimeFormat) async {
    final newSettings = state.copyWith(timeFormat: newTimeFormat);
    state = newSettings;
    await _saveSettings(newSettings);
  }
}
