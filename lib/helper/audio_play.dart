import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration? totalDuration;
  Duration? currentPosition;
  Timer? timer;
  late StreamSubscription<PlayerState> playerStateSubscription;
  late StreamSubscription<Duration> audioPositionSubscription;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    playerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPositionSubscription =
        audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        currentPosition = duration;
      });
    });
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    playerStateSubscription.cancel();
    audioPositionSubscription.cancel();
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (currentPosition! < totalDuration!) {
        setState(() {
          currentPosition = currentPosition!; //+ Duration(milliseconds: 500)
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  Future<void> _playAudio() async {
    Source urlSource = UrlSource(widget.audioUrl);
    await audioPlayer.play(urlSource);
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> _pauseAudio() async {
    await audioPlayer.pause();
    stopTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: isPlaying ? null : _playAudio,
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: (totalDuration?.inMilliseconds.toDouble() ?? 0) + 35.0,
                  value: currentPosition?.inMilliseconds.toDouble() ?? 0,
                  // onChanged: (value) async {
                  //   final int durationInMillis =
                  //       totalDuration?.inMilliseconds ?? 0;
                  //   final double maxValue = durationInMillis.toDouble();
                  //   final double clampedValue = value.clamp(0.0,
                  //       maxValue); // Clamp the value within the valid range
                  //   await audioPlayer
                  //       .seek(Duration(milliseconds: clampedValue.toInt()));
                  //   setState(() {
                  //     currentPosition =
                  //         Duration(milliseconds: clampedValue.toInt());
                  //   });
                  // },

                  onChanged: (value) {
                    setState(() {
                      currentPosition = Duration(milliseconds: value.toInt());
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: isPlaying ? _pauseAudio : null,
              ),
            ],
          ),
          Text(
            isPlaying ? 'Playing' : 'Paused',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
