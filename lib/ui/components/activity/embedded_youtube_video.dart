import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EmbeddedYoutubeVideo extends StatefulWidget {
  final String link;

  const EmbeddedYoutubeVideo({
    required this.link,
    Key? key,
  }) : super(key: key);

  @override
  State<EmbeddedYoutubeVideo> createState() => _EmbeddedYoutubeVideoState();
}

class _EmbeddedYoutubeVideoState extends State<EmbeddedYoutubeVideo> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.link);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      width: 500,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      progressColors: const ProgressBarColors(
        playedColor: Colors.amber,
        handleColor: Colors.amberAccent,
      ),
      onReady: () {
        print("Redy");
      },
    );
  }
}
