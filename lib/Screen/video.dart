import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key, required this.downloadUrl}) : super(key: key);

  final String downloadUrl;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  late ScaffoldMessengerState
      _scaffoldMessengerState; // New variable for Snackbar

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.downloadUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.addListener(_videoPlayerListener);
      });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoPlayerListener);
    _controller.dispose();
    super.dispose();
  }

  void _videoPlayerListener() {
    setState(() {
      _isPlaying = _controller.value.isPlaying ||
          _controller.value.position >= _controller.value.duration;
    });
  }

  Future<void> _downloadAndSaveVideo() async {
    try {
      const String savePath = 'path_to_your_desired_directory/filename.mp4';
      final Dio dio = Dio();
      await dio.download(widget.downloadUrl, savePath);
      final platform = const MethodChannel('channel:gallery_saver');
      await platform.invokeMethod('saveFile', {'filePath': savePath});

      _scaffoldMessengerState.showSnackBar(
        SnackBar(
          content: Text('Video downloaded successfully to: $savePath'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error downloading or saving video: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldMessengerState =
        ScaffoldMessenger.of(context); // Assign the ScaffoldMessengerState

    return Scaffold(
      appBar: AppBar(title: const Text('Video Page')),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        },
                        icon: Icon(
                          _isPlaying ||
                                  _controller.value.position >=
                                      _controller.value.duration
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: VideoProgressIndicator(_controller,
                            allowScrubbing: true),
                      ),
                      IconButton(
                        onPressed: _downloadAndSaveVideo,
                        icon: const Icon(Icons.download),
                      ),
                    ],
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
        home: VideoPage(
            downloadUrl:
                "https://www.example.com/sample.mp4")), // Example video URL
  );
}
