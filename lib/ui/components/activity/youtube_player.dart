import 'dart:async';

import 'package:seagull/ui/all.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayer extends StatefulWidget {
  final String url;

  const YoutubePlayer({required this.url, Key? key}) : super(key: key);

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late final YoutubePlayerController _controller;
  StreamSubscription? _stream;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(widget.url);
    final autoPlayParam = uri.queryParameters['autoplay'];
    final startAtParam = uri.queryParameters['t'];

    final videoId = YoutubePlayerController.convertUrlToId(widget.url);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      params: YoutubePlayerParams(
        strictRelatedVideos: true,
        showFullscreenButton: true,
        startAt: startAtParam != null
            ? Duration(seconds: int.parse(startAtParam))
            : Duration.zero,
      ),
    );
    if (autoPlayParam == '1') _playWhenReady();
  }

  void _playWhenReady() {
    _stream = _controller.listen((event) {
      if (_controller.value.isReady) {
        _controller.play();
        _stream?.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerIFrame(
      controller: _controller,
      aspectRatio: 3,
    );
  }
}
