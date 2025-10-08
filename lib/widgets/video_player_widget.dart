import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double? width;
  final double? height;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      // Pode ser asset ou URL da web
      if (widget.videoUrl.startsWith('assets/')) {
        _controller = VideoPlayerController.asset(widget.videoUrl);
      } else {
        _controller =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      }

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Auto play e loop
        _controller.play();
        _controller.setLooping(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: widget.width ?? 180,
        height: widget.height ?? 120,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Vídeo\nIndisponível',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        width: widget.width ?? 180,
        height: widget.height ?? 120,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      width: widget.width ?? 180,
      height: widget.height ?? 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(_controller),
            if (!_controller.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
