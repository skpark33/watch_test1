import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:watch/core/di/provider.dart';
import 'package:watch/features/clock/presentation/notifiers/time_notifier.dart';
import 'package:watch/features/clock/presentation/widgets/flip_digit.dart';
import 'package:watch/features/clock/domain/entities/clock_settings.dart';
import 'package:watch/features/settings/presentation/widgets/settings_controls.dart';
import 'package:watch/features/world_clock/presentation/pages/world_clock_page.dart';
import 'package:watch/features/world_clock/presentation/widgets/add_city_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb, listEquals;

class ClockPage extends ConsumerStatefulWidget {
  final List<String>? alarmTimes; // "YYYY/MM/DD HH:MM"

  const ClockPage({
    super.key,
    this.alarmTimes,
  });

  @override
  ConsumerState<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends ConsumerState<ClockPage> {
  List<DateTime> _alarmDateTimes = [];
  late List<String> _managedAlarmTimes;
  bool _isAlarmRinging = false;
  Timer? _alarmTimeout;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _timeSubscription;
  bool _isWebAudioReady = !kIsWeb;

  @override
  void initState() {
    super.initState();
    _managedAlarmTimes = List<String>.from(widget.alarmTimes ?? []);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _parseAlarmTime();
      _setupAlarmListener();
    });
  }

  @override
  void didUpdateWidget(covariant ClockPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.alarmTimes, oldWidget.alarmTimes)) {
      setState(() {
        _managedAlarmTimes = List<String>.from(widget.alarmTimes ?? []);
      });
      _dismissAlarm();
      _parseAlarmTime();
      _setupAlarmListener(); // Re-setup listener with new alarm time
    }
  }

  void _parseAlarmTime() {
    _alarmDateTimes = [];
    if (_managedAlarmTimes.isNotEmpty) {
      for (var timeStr in _managedAlarmTimes) {
        try {
          _alarmDateTimes.add(DateFormat('yyyy/MM/dd HH:mm').parse(timeStr));
        } catch (e) {
          debugPrint("Error parsing alarm time: $e");
        }
      }
    }
  }

  void _addAlarm(DateTime newAlarm) {
    final newAlarmString = DateFormat('yyyy/MM/dd HH:mm').format(newAlarm);
    setState(() {
      _managedAlarmTimes.add(newAlarmString);
    });
    _parseAlarmTime();
    _setupAlarmListener();
  }

  void _deleteAlarm(int index) {
    setState(() {
      _managedAlarmTimes.removeAt(index);
    });
    _parseAlarmTime();
    _setupAlarmListener();
  }

  void _setupAlarmListener() {
    _timeSubscription?.cancel(); // Cancel previous subscription
    final timeStream = ref.read(timeNotifierProvider.notifier).stream;
    _timeSubscription = timeStream.listen((now) {
      if (_isAlarmRinging) return;

      final nowTruncated = DateTime(now.year, now.month, now.day, now.hour, now.minute);
      final triggeredAlarm = _alarmDateTimes.firstWhere(
        (alarm) => alarm.isAtSameMomentAs(nowTruncated),
        orElse: () => DateTime(0), // Sentinel value
      );

      if (triggeredAlarm.year != 0) {
        if (mounted) {
          setState(() {
            _alarmDateTimes.remove(triggeredAlarm);
          });
        }
        _triggerAlarm();
      }
    });
  }

  void _triggerAlarm() async {
    if (!mounted) return;
    setState(() {
      _isAlarmRinging = true;
    });

    if (_isWebAudioReady) {
      // NOTE: User must add a sound file to `assets/sounds/`
      // Example: `assets/sounds/alarm.m4a`
      await _audioPlayer.play(AssetSource('sounds/alarm.m4a'), volume: 1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    }

    _alarmTimeout = Timer(const Duration(seconds: 30), () {
      _dismissAlarm();
    });
  }

  void _dismissAlarm() {
    _alarmTimeout?.cancel();
    _audioPlayer.stop();
    if (mounted && _isAlarmRinging) {
      setState(() {
        _isAlarmRinging = false;
      });
    }
  }

  @override
  void dispose() {
    _alarmTimeout?.cancel();
    _timeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clockView = ref.watch(clockViewProvider);

    final pageContent = Scaffold(
      backgroundColor: _isAlarmRinging ? Colors.red.withOpacity(0.7) : null,
      appBar: AppBar(
        title: Text(clockView == ClockView.main ? 'Digital Clock' : 'World Clock'),
        actions: [
          if (clockView == ClockView.world)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddCityDialog(),
                );
              },
            ),
          IconButton(
            icon: Icon(
              clockView == ClockView.main ? Icons.public : Icons.watch_later,
            ),
            onPressed: () {
              if (_isAlarmRinging) return; // Prevent navigation while alarm is ringing
              final notifier = ref.read(clockViewProvider.notifier);
              notifier.state = clockView == ClockView.main ? ClockView.world : ClockView.main;
            },
          ),
        ],
      ),
      body: clockView == ClockView.main
          ? MainClockView(
              isAlarmRinging: _isAlarmRinging,
              onDismissAlarm: _dismissAlarm,
              alarmTimes: _managedAlarmTimes,
              onAddAlarm: _addAlarm,
              onDeleteAlarm: _deleteAlarm,
            )
          : const WorldClockPage(),
    );

    if (!_isWebAudioReady) {
      return Stack(
        children: [
          pageContent,
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                await _audioPlayer.resume();
                if (mounted) {
                  setState(() {
                    _isWebAudioReady = true;
                  });
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    '웹에서는 소리를 재생하려면 화면을 한 번 클릭해야 합니다.\nClick to enable sound.',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return pageContent;
  }
}

class MainClockView extends ConsumerWidget {
  final bool isAlarmRinging;
  final VoidCallback onDismissAlarm;
  final List<String>? alarmTimes;
  final Function(DateTime) onAddAlarm;
  final Function(int) onDeleteAlarm;

  const MainClockView({
    super.key,
    this.isAlarmRinging = false,
    required this.onDismissAlarm,
    this.alarmTimes,
    required this.onAddAlarm,
    required this.onDeleteAlarm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTime = ref.watch(timeNotifierProvider);
    final timeStream = ref.read(timeNotifierProvider.notifier).stream;
    final settings = ref.watch(settingsProvider);
    final fontStyle = ref.watch(fontProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Date and Day display
          asyncTime.when(
            data: (time) => Text(
              DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(time),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            loading: () => const SizedBox(height: 30),
            error: (err, stack) => const Text('Error'),
          ),
          const SizedBox(height: 20),
          // Flip Clock
          asyncTime.when(
            data: (time) =>
                _buildClockDisplay(context, time, timeStream, settings.timeFormat, fontStyle),
            loading: () => _buildClockDisplay(
                context, DateTime.now(), const Stream.empty(), settings.timeFormat, fontStyle),
            error: (err, stack) => const Text('Error displaying clock'),
          ),
          const SizedBox(height: 40),
          // Settings Controls
          SettingsControls(
            isAlarmRinging: isAlarmRinging,
            onDismissAlarm: onDismissAlarm,
            alarmTimes: alarmTimes,
            onAddAlarm: onAddAlarm,
            onDeleteAlarm: onDeleteAlarm,
          ),
        ],
      ),
    );
  }

  Widget _buildClockDisplay(BuildContext context, DateTime time, Stream<DateTime> stream,
      TimeFormat timeFormat, TextStyle fontStyle) {
    int hour = time.hour;
    String amPm = '';

    if (timeFormat == TimeFormat.h12) {
      amPm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12; // 12 AM and 12 PM
    }

    final minute = time.minute;
    final second = time.second;

    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.dark ? Colors.white : Colors.black87;

    final textStyle = fontStyle.copyWith(color: textColor);

    final digitWidth = 100.0;
    final digitHeight = 150.0;
    final digitBackgroundColor = Theme.of(context).colorScheme.surface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timeFormat == TimeFormat.h12) ...[
          Text(amPm, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(width: 16),
        ],
        // Hour
        FlipDigit(
          initialValue: hour ~/ 10,
          stream: stream.map((t) {
            int h = t.hour;
            if (timeFormat == TimeFormat.h12) {
              h = h % 12;
              if (h == 0) h = 12;
            }
            return h ~/ 10;
          }).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        const SizedBox(width: 8),
        FlipDigit(
          initialValue: hour % 10,
          stream: stream.map((t) {
            int h = t.hour;
            if (timeFormat == TimeFormat.h12) {
              h = h % 12;
              if (h == 0) h = 12;
            }
            return h % 10;
          }).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        _buildSeparator(context, fontStyle),
        // Minute
        FlipDigit(
          initialValue: minute ~/ 10,
          stream: stream.map((t) => t.minute ~/ 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        const SizedBox(width: 8),
        FlipDigit(
          initialValue: minute % 10,
          stream: stream.map((t) => t.minute % 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        _buildSeparator(context, fontStyle),
        // Second
        FlipDigit(
          initialValue: second ~/ 10,
          stream: stream.map((t) => t.second ~/ 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
        const SizedBox(width: 8),
        FlipDigit(
          initialValue: second % 10,
          stream: stream.map((t) => t.second % 10).distinct(),
          textStyle: textStyle,
          width: digitWidth,
          height: digitHeight,
          backgroundColor: digitBackgroundColor,
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context, TextStyle fontStyle) {
    final brightness = Theme.of(context).brightness;
    final separatorColor = brightness == Brightness.dark ? Colors.white54 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: fontStyle.fontFamily,
          fontSize: Theme.of(context).textTheme.displayLarge?.fontSize,
          fontWeight: FontWeight.bold,
          color: separatorColor,
        ),
      ),
    );
  }
}
