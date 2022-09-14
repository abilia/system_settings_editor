import 'package:seagull/db/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/ui/all.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt;

class YoutubePlayer extends StatefulWidget {
  final String url;

  const YoutubePlayer({required this.url, Key? key}) : super(key: key);

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late final yt.YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final videoId = yt.YoutubePlayerController.convertUrlToId(
      widget.url.startsWith('http') ? widget.url : 'https://${widget.url}',
    );
    _controller = yt.YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      params: yt.YoutubePlayerParams(
        strictRelatedVideos: true,
        showVideoAnnotations: false,
        interfaceLanguage: GetIt.I<SettingsDb>().language,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // As of youtube_player_iframe 3.0.4 the player fixes it's aspectratio to
      // MediaQuery.of(context).size.aspectRatio
      // if orientation == Orientation.landscape
      // So this ugly hack for forcing correct aspect ration
      // Please someone in the future, just replace this stupid plugin with
      // an ordinary WebView
      data: MediaQuery.of(context).copyWith(size: const Size(16, 9)),
      child: yt.YoutubePlayer(controller: _controller),
    );
  }
}
