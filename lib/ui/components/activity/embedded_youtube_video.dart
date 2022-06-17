import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/all.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EmbeddedYoutubePlayer extends StatefulWidget {
  final InfoItem infoItem;
  final Widget Function(BuildContext, Widget) builder;

  const EmbeddedYoutubePlayer({
    required this.infoItem,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  State<EmbeddedYoutubePlayer> createState() => _EmbeddedYoutubePlayerState();
}

class _EmbeddedYoutubePlayerState extends State<EmbeddedYoutubePlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final url = widget.infoItem is UrlInfoItem
        ? (widget.infoItem as UrlInfoItem).url
        : '';
    final videoId = YoutubePlayer.convertUrlToId(url);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          width: 500,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          progressColors: const ProgressBarColors(
            playedColor: Colors.amber,
            handleColor: Colors.amberAccent,
          ),
          onReady: () {},
        ),
        builder: (context, player) {
          final child = widget.builder(context, player);
          return child;
        });
  }
}
