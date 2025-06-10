import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:watch/core/di/provider.dart';
import 'package:watch/core/theme/app_theme.dart';
import 'package:watch/features/clock/presentation/pages/clock_page.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  // Initialize timezone data
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);

    return sharedPreferencesAsync.when(
      data: (_) {
        final settings = ref.watch(settingsProvider);
        return MaterialApp(
          title: 'Digital Clock',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: Center(
            child: Container(
              width: 1920,
              height: 400,
              decoration: BoxDecoration(
                //color: Colors.red,
                border: Border.all(color: Colors.blue, width: 10),
              ),
              child: const ClockPage(
                alarmTimes: ['2025/06/10 18:01', '2025/06/10 18:02'],
              ),
            ),
          ),
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
