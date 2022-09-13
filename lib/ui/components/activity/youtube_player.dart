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

  @override
  void initState() {
    super.initState();
    final url =
        widget.url.startsWith('http') ? widget.url : 'https://${widget.url}';
    final videoId = YoutubePlayerController.convertUrlToId(url);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      params: const YoutubePlayerParams(
        strictRelatedVideos: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      builder: (context, player) => player,
      controller: _controller,
      aspectRatio: 3,
    );
  }
}
