import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/storage/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:video_player/video_player.dart' as player;

class VideoPlayer extends StatefulWidget {
  final String fileId;
  final bool isEditActvity;

  const VideoPlayer({
    required this.fileId,
    this.isEditActvity = false,
    super.key,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  player.VideoPlayerController? _controller;

  Future<File?> _getVideoFile(String id) async {
    final file = GetIt.I.get<FileStorage>().getFile(id);
    final isDirectory = await file.stat().then((fileStat) {
      return fileStat.type == FileSystemEntityType.directory;
    }).catchError((error) {
      return false;
    });
    return isDirectory ? null : file;
  }

  @override
  void initState() {
    super.initState();
    refreshController(widget.fileId);
  }

  Future<void> refreshController(String fileId) async {
    _controller?.dispose();
    final file = await _getVideoFile(fileId);
    if (file == null) return;
    _controller = player.VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {});
      });
    if (widget.isEditActvity) {
      _controller?.setLooping(true);
      _controller?.play();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final hasVideo = widget.fileId.isNotEmpty;
    final isInitialized = controller != null && controller.value.isInitialized;
    final child = BlocBuilder<PermissionCubit, PermissionState>(
      builder: (context, permissionState) => GestureDetector(
        onTap: _playOrPause,
        child: hasVideo && isInitialized
            ? player.VideoPlayer(controller)
            : Container(),
      ),
    );
    return widget.isEditActvity
        ? BlocListener<EditActivityCubit, EditActivityState>(
            listenWhen: (previous, current) =>
                previous.activity.infoItem != current.activity.infoItem &&
                current.activity.infoItem is VideoInfoItem,
            listener: (context, state) => refreshController(
              (state.activity.infoItem as VideoInfoItem).fileId,
            ),
            child: child,
          )
        : BlocListener<ActivityCubit, ActivityState>(
            listenWhen: (previous, current) =>
                current is ActivityLoaded &&
                current.activityDay.activity.infoItem is VideoInfoItem,
            listener: (context, state) => refreshController(
              ((state as ActivityLoaded).activityDay.activity.infoItem
                      as VideoInfoItem)
                  .fileId,
            ),
            child: child,
          );
  }

  void _playOrPause() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }
}
