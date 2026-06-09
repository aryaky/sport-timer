import 'dart:async';

import 'package:flutter/material.dart';

// import 'audio/beep_player.dart';
import 'engine/timer_engine.dart';
import 'widgets/done_view.dart';
import 'widgets/setup_view.dart';
import 'widgets/timer_view.dart' as timer_widget;

void main() {
  runApp(const SportTimerApp());
}

class SportTimerApp extends StatelessWidget {
  const SportTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '运动计时器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
        ),
        fontFamily: '.SF Pro Display',
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const SportTimerHome(),
    );
  }
}

class SportTimerHome extends StatefulWidget {
  const SportTimerHome({super.key});

  @override
  State<SportTimerHome> createState() => _SportTimerHomeState();
}

class _SportTimerHomeState extends State<SportTimerHome> {
  final TimerEngine _engine = TimerEngine();
  // final BeepPlayer _beepPlayer = BeepPlayer();
  Timer? _timer;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // _beepPlayer.dispose();
    super.dispose();
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      // if (_engine.isRunning && _engine.remaining <= 3 && _engine.remaining > 0) {
      //   _beepPlayer.playCountdown();
      // }

      final change = _engine.tick();

      if (change.isDone) {
        _timer?.cancel();
        // _beepPlayer.playDone();
        setState(() {});
        return;
      }

      // if (change.isPhaseSwitch) {
      //   _beepPlayer.playPhaseStart();
      // }

      setState(() {});
    });
  }

  void _onStart(int rounds, int exercise, int rest) {
    _engine.configure(rounds, exercise, rest);
    _engine.start();
    // _beepPlayer.playPhaseStart();
    _startTick();
    setState(() {});
  }

  void _onPause() {
    _engine.pause();
    _timer?.cancel();
    setState(() {});
  }

  void _onResume() {
    _engine.resume();
    _startTick();
    setState(() {});
  }

  void _onReset() {
    _timer?.cancel();
    _engine.reset();
    setState(() {});
  }

  void _onRedo() {
    _engine.reset();
    setState(() {});
  }

  void _onMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  int _calculateTotalMinutes() {
    final totalSec = _engine.exerciseSec * _engine.totalRounds +
        _engine.restSec * (_engine.totalRounds - 1);
    return (totalSec / 60).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_engine.view) {
      case TimerView.setup:
        return SetupView(
          onStart: _onStart,
          onMinimize: _onMinimize,
        );
      case TimerView.running:
      case TimerView.paused:
        return timer_widget.TimerView(
          engine: _engine,
          isMinimized: _isMinimized,
          onPause: _onPause,
          onResume: _onResume,
          onReset: _onReset,
          onMinimize: _onMinimize,
        );
      case TimerView.done:
        return DoneView(
          totalRounds: _engine.totalRounds,
          totalMinutes: _calculateTotalMinutes(),
          onRedo: _onRedo,
        );
    }
  }
}
