import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:video_compress/video_compress.dart';

class InfoItemTab extends StatefulWidget with EditActivityTab {
  final bool showNote, showChecklist;

  const InfoItemTab({
    required this.showNote,
    required this.showChecklist,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => InfoItemTabState();
}

class InfoItemTabState extends State<InfoItemTab> {
  Timer? _showWarningToastTimer;

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final videoFeatureToggle = context.select((FeatureToggleCubit cubit) =>
        cubit.state.isToggleEnabled(FeatureToggle.videoInActivity));

    return Padding(
      padding: layout.templates.m3.withoutBottom,
      child: BlocSelector<EditActivityCubit, EditActivityState, InfoItem>(
        selector: (state) => state.activity.infoItem,
        builder: (context, infoItem) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.showChecklist)
                      GestureDetector(
                        onTap: infoItem is! NoInfoItem && infoItem is! Checklist
                            ? _setShowErrorMessage
                            : null,
                        child: InfoItemPickField<Checklist>(
                          text: translate.checklist,
                          iconData: AbiliaIcons.ok,
                          infoItem: infoItem,
                        ),
                      ),
                    SizedBox(height: layout.formPadding.verticalItemDistance),
                    if (widget.showNote)
                      GestureDetector(
                        onTap:
                            infoItem is! NoInfoItem && infoItem is! NoteInfoItem
                                ? _setShowErrorMessage
                                : null,
                        child: InfoItemPickField<NoteInfoItem>(
                          text: translate.note,
                          iconData: AbiliaIcons.edit,
                          infoItem: infoItem,
                        ),
                      ),
                    SizedBox(height: layout.formPadding.verticalItemDistance),
                    if (videoFeatureToggle || infoItem is VideoInfoItem) ...[
                      InfoItemPickField<VideoInfoItem>(
                        text: 'Video',
                        iconData: AbiliaIcons.videoCall,
                        infoItem: infoItem,
                      ),
                      SizedBox(height: layout.formPadding.verticalItemDistance),
                      if (infoItem is VideoInfoItem) ...[
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: VideoPlayer(
                              isEditActivity: true,
                              fileId: infoItem.fileId,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: layout.formPadding.verticalItemDistance),
                      ],
                    ],
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CollapsableWidget(
                  collapsed: _showWarningToastTimer == null,
                  padding: EdgeInsets.only(bottom: layout.templates.m3.bottom),
                  child: ErrorMessage(
                    text: Text(Lt.of(context).onlyOneInfoItem),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _setShowErrorMessage() {
    setState(() {
      _showWarningToastTimer = Timer(
        const Duration(milliseconds: 6000),
        () => setState(
          () {
            _showWarningToastTimer?.cancel();
            _showWarningToastTimer = null;
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _showWarningToastTimer?.cancel();
    super.dispose();
  }
}

class InfoItemPickField<InfoItemType extends InfoItem> extends StatelessWidget {
  final InfoItem infoItem;
  final String text;
  final IconData iconData;

  const InfoItemPickField({
    required this.infoItem,
    required this.text,
    required this.iconData,
    super.key,
  });

  bool get ofCorrectType => infoItem is InfoItemType;

  @override
  Widget build(BuildContext context) {
    final infoItem = this.infoItem;
    final permissionState = context.watch<PermissionCubit>().state;
    return Row(
      children: [
        Expanded(
          child: PickField(
            leading: Icon(iconData),
            text: Text(text),
            extras: ofCorrectType
                ? InfoItemPickFieldExtras(infoItem: infoItem)
                : null,
            onTap: infoItem is NoInfoItem || ofCorrectType
                ? () async {
                    if (InfoItemType == VideoInfoItem) {
                      return _recordNewVideo(context, permissionState);
                    }
                    final editActivityCubit = context.read<EditActivityCubit>();
                    final providers = [
                      ...copiedAuthProviders(context),
                      BlocProvider.value(value: editActivityCubit)
                    ];
                    await Navigator.of(context).push<Type>(
                      PersistentMaterialPageRoute(
                        settings:
                            (AddInfoTypePage<InfoItemType>).routeSetting(),
                        builder: (context) => MultiBlocProvider(
                          providers: providers,
                          child: AddInfoTypePage<InfoItemType>(),
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ),
        if (ofCorrectType) ...[
          SizedBox(
            width: layout.formPadding.verticalItemDistance,
          ),
          IconActionButtonDark(
            onPressed: () async {
              context.read<EditActivityCubit>().removeInfoItem();
            },
            child: const Icon(AbiliaIcons.deleteAllClear),
          ),
        ]
      ],
    );
  }

  Future<void> _recordNewVideo(
    BuildContext context,
    PermissionState permissionState,
  ) async {
    if (permissionState.status[Permission.camera]?.isPermanentlyDenied ==
        true) {
      return;
    }
    try {
      final video = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: 5.minutes(),
      );
      if (video != null && context.mounted) {
        return _addVideo(context, video.path);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _addVideo(
    BuildContext context,
    String path,
  ) async {
    final userFileBloc = context.read<UserFileBloc>();
    final editActivityCubit = context.read<EditActivityCubit>();
    File? file = File(path);
    double sizeInMB = file.lengthSync() / 1024 / 1024;

    if (sizeInMB > 10) {
      final mediaInfo = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: true,
      );
      file = mediaInfo?.file;
    }

    if (file != null) {
      sizeInMB = file.lengthSync() / 1024 / 1024;
      if (sizeInMB < 10) {
        final abiliaFile = UnstoredAbiliaFile.newFile(file);
        userFileBloc.add(
          FileAdded(
            abiliaFile,
            isImage: false,
          ),
        );
        editActivityCubit.replaceActivity(
          editActivityCubit.state.activity.copyWith(
            infoItem: VideoInfoItem(abiliaFile.id),
          ),
        );
      }
    }
  }
}

class InfoItemPickFieldExtras extends StatelessWidget {
  final InfoItem infoItem;

  const InfoItemPickFieldExtras({
    required this.infoItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final infoItem = this.infoItem;
    if (infoItem is NoteInfoItem) {
      return NoteInfoItemPickFieldExtras(
        note: infoItem,
      );
    }
    if (infoItem is Checklist) {
      return ChecklistPickFieldExtras(
        checklist: infoItem,
      );
    }
    return const SizedBox.shrink();
  }
}

class NoteInfoItemPickFieldExtras extends StatelessWidget {
  final NoteInfoItem note;

  const NoteInfoItemPickFieldExtras({
    required this.note,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: layout.formPadding.horizontalItemDistance),
      child: SizedBox(
        height: layout.note.previewExtrasHeight,
        child: Text(
          note.text.replaceAll('\n', ' '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: bodyMedium,
        ),
      ),
    );
  }
}

class ChecklistPickFieldExtras extends StatelessWidget {
  final Checklist checklist;

  const ChecklistPickFieldExtras({
    required this.checklist,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final questions = checklist.questions;
    final translate = Lt.of(context);
    final checklistLayout = layout.checklist;
    return Container(
      height: checklistLayout.previewExtrasHeight,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(checklistLayout.previewCornerRadius),
        color: AbiliaColors.white110,
      ),
      padding: checklistLayout.previewPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${questions.length} ${translate.tasks}'),
          SizedBox(width: checklistLayout.previewListPadding),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: questions
                  .map(
                    (question) => CheckListPickFieldExtrasItem(
                      question: question,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckListPickFieldExtrasItem extends StatelessWidget {
  final Question question;

  const CheckListPickFieldExtrasItem({
    required this.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final checklistLayout = layout.checklist;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: EdgeInsets.only(
        right: checklistLayout.previewItemSpacing,
      ),
      decoration: BoxDecoration(
        color: AbiliaColors.white,
        borderRadius: BorderRadius.circular(
          checklistLayout.previewItemCornerRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (question.hasImage) ...[
            FadeInCalendarImage(
              imageFile: AbiliaFile.from(
                id: question.fileId,
                path: question.image,
              ),
              width: checklistLayout.previewImageSize,
              height: checklistLayout.previewImageSize,
              radius: BorderRadius.all(
                Radius.circular(checklistLayout.previewImageBorderRadius),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(question.name, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
