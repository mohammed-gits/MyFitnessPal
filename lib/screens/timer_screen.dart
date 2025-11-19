import 'dart:async';
import 'package:flutter/material.dart';

class RestTimerPage extends StatefulWidget {
  final int initialSeconds;

  const RestTimerPage({
    super.key,
    this.initialSeconds = 45,
  });

  @override
  State<RestTimerPage> createState() => _RestTimerPageState();
}

class _RestTimerPageState extends State<RestTimerPage> {
  late int _secondsLeft;
  late int _maxSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _maxSeconds = widget.initialSeconds;
    _isRunning = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //TIMER LOGIC

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _isRunning = false;
        });
        return;
      }
      setState(() {
        _secondsLeft--;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      if (_secondsLeft > 0) {
        _startTimer();
      }
    }
  }

  void _changeSeconds(int delta) {
    setState(() {
      _secondsLeft += delta;

      if (_secondsLeft < 0) _secondsLeft = 0;

      if (_secondsLeft > _maxSeconds) {
        _maxSeconds = _secondsLeft;
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  double get _progress {
    if (_maxSeconds == 0) return 0;
    return _secondsLeft / _maxSeconds;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest timer'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Take a short rest',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adjust the time if you need more or less rest.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 10,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(_secondsLeft),
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRunning
                                  ? 'Counting down...'
                                  : 'Ready / Paused',
                              style:
                              theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => _changeSeconds(-30),
                    child: const Text('- 30s'),
                  ),
                  OutlinedButton(
                    onPressed: () => _changeSeconds(30),
                    child: const Text('+ 30s'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _toggleTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Pause' : 'Start'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      _pauseTimer();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
