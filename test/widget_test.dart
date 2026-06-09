import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sport_timer/engine/timer_engine.dart';
import 'package:sport_timer/theme/app_theme.dart';

void main() {
  group('TimerEngine', () {
    late TimerEngine engine;

    setUp(() {
      engine = TimerEngine();
    });

    test('initial state is setup', () {
      expect(engine.view, TimerView.setup);
      expect(engine.phase, Phase.exercise);
      expect(engine.currentRound, 1);
      expect(engine.remaining, greaterThanOrEqualTo(0));
    });

    test('configure sets parameters correctly', () {
      engine.configure(5, 60, 20);
      expect(engine.totalRounds, 5);
      expect(engine.exerciseSec, 60);
      expect(engine.restSec, 20);
      expect(engine.view, TimerView.setup);
    });

    test('start begins first exercise round', () {
      engine.configure(3, 45, 15);
      engine.start();
      expect(engine.view, TimerView.running);
      expect(engine.phase, Phase.exercise);
      expect(engine.currentRound, 1);
      expect(engine.remaining, 45);
      expect(engine.phaseDuration, 45);
    });

    test('tick decrements remaining', () {
      engine.configure(3, 45, 15);
      engine.start();
      final change = engine.tick();
      expect(change.isDone, false);
      expect(change.isPhaseSwitch, false);
      expect(engine.remaining, 44);
    });

    test('tick switches to rest after exercise ends', () {
      engine.configure(3, 2, 1);
      engine.start();
      engine.tick(); // remaining: 1
      final change = engine.tick(); // remaining: 0 -> switch to rest
      expect(change.isPhaseSwitch, true);
      expect(change.newPhase, Phase.rest);
      expect(engine.phase, Phase.rest);
      expect(engine.remaining, 1); // restSec = 1
    });

    test('tick finishes after all rounds', () {
      engine.configure(1, 1, 0); // 1 round, 1 sec exercise
      engine.start();
      final change = engine.tick(); // remaining: 0, only 1 round -> done
      expect(change.isDone, true);
      expect(engine.view, TimerView.done);
    });

    test('tick switches between exercise and rest across rounds', () {
      engine.configure(2, 1, 1);
      engine.start();

      // Round 1 exercise -> rest
      var change = engine.tick();
      expect(change.isPhaseSwitch, true);
      expect(change.newPhase, Phase.rest);
      expect(engine.phase, Phase.rest);
      expect(engine.currentRound, 1);

      // Rest -> Round 2 exercise
      change = engine.tick();
      expect(change.isPhaseSwitch, true);
      expect(change.newPhase, Phase.exercise);
      expect(change.newRound, 2);
      expect(engine.phase, Phase.exercise);
      expect(engine.currentRound, 2);

      // Round 2 exercise -> done
      change = engine.tick();
      expect(change.isDone, true);
      expect(engine.view, TimerView.done);
    });

    test('pause and resume work correctly', () {
      engine.configure(3, 45, 15);
      engine.start();
      engine.pause();
      expect(engine.view, TimerView.paused);
      engine.resume();
      expect(engine.view, TimerView.running);
    });

    test('reset returns to setup', () {
      engine.configure(3, 45, 15);
      engine.start();
      engine.tick();
      engine.reset();
      expect(engine.view, TimerView.setup);
      expect(engine.currentRound, 1);
    });

    test('progress calculates correctly', () {
      engine.configure(3, 100, 50);
      engine.start();
      // remaining=100, phaseDuration=100 -> progress=0
      expect(engine.progress, closeTo(0.0, 0.01));
      engine.remaining = 50;
      expect(engine.progress, closeTo(0.5, 0.01));
      engine.remaining = 0;
      expect(engine.progress, closeTo(1.0, 0.01));
    });

    test('tick returns noChange when not running', () {
      engine.configure(3, 45, 15);
      final change = engine.tick();
      expect(change.isDone, false);
      expect(change.isPhaseSwitch, false);
      expect(engine.view, TimerView.setup);
    });
  });

  group('AppTheme', () {
    test('exerciseGradient has correct colors', () {
      expect(AppTheme.exerciseGradient.length, 2);
      expect(AppTheme.exerciseGradient[0], const Color(0xFFFF6B35));
      expect(AppTheme.exerciseGradient[1], const Color(0xFFF7931E));
    });

    test('restGradient has correct colors', () {
      expect(AppTheme.restGradient.length, 2);
      expect(AppTheme.restGradient[0], const Color(0xFF00B4D8));
    });

    test('doneGradient has correct colors', () {
      expect(AppTheme.doneGradient.length, 2);
    });

    test('cardRadius is positive', () {
      expect(AppTheme.cardRadius, greaterThan(0));
    });
  });
}
