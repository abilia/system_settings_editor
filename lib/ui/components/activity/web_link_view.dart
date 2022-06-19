import 'dart:io';

import 'package:seagull/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  // YoutubePlayerController? _youtubeController;
  YoutubePlayerController? _iFrameController;
  late final String? _videoId;

  @override
  void initState() {
    super.initState();
    // _videoId = YoutubePlayer.convertUrlToId(widget.url);
    // if (_videoId != null) {
    //   _youtubeController = YoutubePlayerController(
    //     initialVideoId: _videoId!,
    //     flags: const YoutubePlayerFlags(
    //       enableCaption: false,
    //       hideThumbnail: true,
    //       autoPlay: false,
    //       mute: false,
    //     ),
    //   );
    // }
    _videoId = YoutubePlayerController.convertUrlToId(widget.url);
    if (_videoId != null) {
      _iFrameController = YoutubePlayerController(
        initialVideoId: _videoId!,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
        ),
      );
      // _iFrameController!.listen((event) {
          // print("_isFullScreen: ${_isFullScreen}");
          // print("event.isFullScreen: ${event.isFullScreen}");
          // if (_isFullScreen != _iFrameController!.value.isFullScreen) {
          //   _isFullScreen = _iFrameController!.value.isFullScreen;
          // }
      // });
    }
    else if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }

  @override
  void dispose() {
    super.dispose();
    // if (_youtubeController != null) {
    //   _youtubeController!.dispose();
    // }
  }

  @override
  Widget build(BuildContext context) {
    // if (_youtubeController != null) {
    //   return YoutubePlayerBuilder(
    //       player: YoutubePlayer(
    //         controller: _youtubeController!,
    //         showVideoProgressIndicator: true,
    //         progressIndicatorColor: Colors.amber,
    //         progressColors: const ProgressBarColors(
    //           playedColor: Colors.amber,
    //           handleColor: Colors.amberAccent,
    //         ),
    //         onReady: () {},
    //       ),
    //       builder: (context, player) {
    //         final child = widget.builder(context, player);
    //         return child;
    //       });
    // }
    if (_iFrameController != null) {
      final youtubePlayer = YoutubePlayerIFrame(
        controller: _iFrameController,
      );
      final child =  widget.builder(context, youtubePlayer);
      return child;
    }
    final webView = WebView(
      initialUrl: widget.url,
    );
    final child = widget.builder(context, webView);
    return child;
  }
}
