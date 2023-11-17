import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget(this.path, {Key? key}) : super(key: key);

  final String path;

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool isPlaying = false;
  String path = "";
  late Source urlSource;

  Duration duration = Duration();
  Duration position = Duration();

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    urlSource = UrlSource(widget.path);
  }

  Future<void> playPauseAudio() async {
    try {
      // await AudioPlayer().play(urlSource);
      await audioPlayer.play(AssetSource("audio-file.flac"));
      setState(() {
        isPlaying = true;
      });

      audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Error: Could not play audio"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff2e2e2e),
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: playPauseAudio,
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF277AFF),
                    Color(0xFF12307C),
                  ],
                ),
                borderRadius: BorderRadius.circular(32.0),
              ),
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                size: 24.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Slider(
            value: position.inSeconds.toDouble(),
            min: 0.0,
            max: duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
        ],
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final BuildContext context;
  final String audioPath;
  final bool isRecording;
  final VoidCallback startRecording;
  final VoidCallback stopRecording;

  const BottomBar({
    Key? key,
    required this.context,
    required this.audioPath,
    required this.isRecording,
    required this.startRecording,
    required this.stopRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: audioPath.isNotEmpty
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          if (audioPath.isNotEmpty) ...[
            AudioPlayerWidget(audioPath),
            const SizedBox(width: 16),
          ],
          GestureDetector(
            onTap: isRecording ? stopRecording : startRecording,
            child: Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF277AFF),
                    Color(0xFF12307C),
                  ],
                ),
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.graphic_eq,
                size: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
