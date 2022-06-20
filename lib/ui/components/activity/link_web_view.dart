import 'package:seagull/ui/all.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LinkWebView extends StatelessWidget {
  final String url;

  const LinkWebView({required this.url, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(url);
    final autoPlay = uri.queryParameters['autoplay'];
    final startAt = uri.queryParameters['t'];

    // If videoId is equal to null, the url is not a youtube video.
    // For future implementation of more weblinks, check if videoId is null and if not, display a WebView instead of a YoutubePlayer.
    final videoId = YoutubePlayerController.convertUrlToId(url);
    final controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      params: YoutubePlayerParams(
        strictRelatedVideos: true,
        showFullscreenButton: true,
        autoPlay: autoPlay == '1',
        startAt: startAt != null
            ? Duration(seconds: int.parse(startAt))
            : Duration.zero,
      ),
    );
    return YoutubePlayerIFrame(
      controller: controller,
      aspectRatio: 3,
    );
  }
}
