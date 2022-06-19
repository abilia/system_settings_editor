import 'dart:io';

import 'package:seagull/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WebLinkView extends StatefulWidget {
  final String url;
  final Widget Function(BuildContext, Widget) builder;

  const WebLinkView({
    required this.url,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  State<WebLinkView> createState() => _WebLinkViewState();
}

class _WebLinkViewState extends State<WebLinkView> {
  YoutubePlayerController? _youtubeController;
  late final String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (_videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(
          enableCaption: false,
          hideThumbnail: true,
          autoPlay: false,
          mute: false,
        ),
      );
    } else if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_youtubeController != null) {
      _youtubeController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_youtubeController != null) {
      return YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _youtubeController!,
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
    final webView = WebView(
      initialUrl: widget.url,
    );
    final child = widget.builder(context, webView);
    return child;
  }
}
