import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:video_compress/video_compress.dart';

class InfoItemTab extends StatelessWidget with EditActivityTab {
  final bool showNote, showChecklist;

  const InfoItemTab({
    required this.showNote,
    required this.showChecklist,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: layout.templates.m3,
        child: BlocSelector<EditActivityCubit, EditActivityState, InfoItem>(
          selector: (state) => state.activity.infoItem,
          builder: (context, infoItem) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SubHeading(Lt.of(context).infoType),
              PickInfoItem(
                showChecklist: showChecklist,
                showNote: showNote,
                infoItem: infoItem,
              ),
              SizedBox(height: layout.formPadding.largeVerticalItemDistance),
              if (infoItem is Checklist)
                const EditChecklistWidget()
              else if (infoItem is NoteInfoItem)
                EditNoteWidget(infoItem: infoItem)
              else if (infoItem is VideoInfoItem)
                AddVideoWidget(infoItem: infoItem),
            ],
          ),
        ),
      );
}

class PickInfoItem extends StatelessWidget {
  final bool showChecklist, showNote;
  final InfoItem infoItem;
  const PickInfoItem({
    required this.showChecklist,
    required this.showNote,
    required this.infoItem,
    Key? key,
  }) : super(key: key);

  bool get isChecklist => infoItem is Checklist;
  bool get isNote => infoItem is NoteInfoItem;
  bool get isVideo => infoItem is VideoInfoItem;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          ChangeInfoItemPicker(
            infoItem,
            showChecklist: showChecklist,
            showNote: showNote,
          ),
          if (isChecklist || isNote) ...[
            SizedBox(width: layout.formPadding.horizontalItemDistance),
            LibraryButton(
              infoItem: infoItem,
            ).pad(layout.templates.s3)
          ] else if (isVideo) ...[
            SizedBox(width: layout.formPadding.horizontalItemDistance),
            const AddVideoButton().pad(layout.templates.s3)
          ],
        ],
      );
}

class ChangeInfoItemPicker extends StatelessWidget {
  final InfoItem infoItem;
  final bool showChecklist, showNote;

  const ChangeInfoItemPicker(
    this.infoItem, {
    required this.showChecklist,
    required this.showNote,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: PickField(
          leading: _icon(infoItem),
          text: Text(_text(Lt.of(context), infoItem)),
          onTap: () async {
            final featureToggleCubit = context.read<FeatureToggleCubit>();
            final editActivityCubit = context.read<EditActivityCubit>();
            final result = await Navigator.of(context).push<Type>(
              PersistentMaterialPageRoute(
                settings: (SelectInfoTypePage).routeSetting(),
                builder: (context) => BlocProvider<FeatureToggleCubit>.value(
                  value: featureToggleCubit,
                  child: SelectInfoTypePage(
                    infoItemType: infoItem.runtimeType,
                    showChecklist: showChecklist,
                    showNote: showNote,
                  ),
                ),
              ),
            );
            if (result != null) {
              editActivityCubit.changeInfoItemType(result);
            }
          },
        ),
      );

  String _text(Lt t, InfoItem infoItem) {
    if (infoItem is Checklist) {
      return t.addChecklist;
    } else if (infoItem is NoteInfoItem) {
      return t.addNote;
    } else if (infoItem is VideoInfoItem) {
      return 'Add video';
    }
    return t.infoTypeNone;
  }

  Icon _icon(InfoItem infoItem) {
    if (infoItem is Checklist) {
      return const Icon(AbiliaIcons.ok);
    } else if (infoItem is NoteInfoItem) {
      return const Icon(AbiliaIcons.edit);
    } else if (infoItem is VideoInfoItem) {
      return const Icon(AbiliaIcons.videoCall);
    }
    return const Icon(AbiliaIcons.information);
  }
}

class LibraryButton extends StatelessWidget {
  final InfoItem infoItem;

  bool get isChecklist => infoItem is Checklist;

  const LibraryButton({
    required this.infoItem,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => IconActionButtonDark(
        onPressed: () async {
          final authProviders = copiedAuthProviders(context);
          final editActivityCubit = context.read<EditActivityCubit>();
          final infoItem = await Navigator.of(context).push<InfoItem>(
            PersistentMaterialPageRoute(
              settings: (isChecklist ? ChecklistLibraryPage : NoteLibraryPage)
                  .routeSetting(),
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: isChecklist
                    ? const ChecklistLibraryPage()
                    : const NoteLibraryPage(),
              ),
            ),
          );
          if (infoItem != null && infoItem != this.infoItem) {
            editActivityCubit.replaceActivity(
              editActivityCubit.state.activity.copyWith(infoItem: infoItem),
            );
          }
        },
        child: Icon(
          AbiliaIcons.showText,
          size: layout.icon.normal,
          color: AbiliaColors.black,
        ),
      );
}

class AddVideoButton extends StatelessWidget {
  const AddVideoButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PermissionCubit, PermissionState>(
        builder: (context, permissionState) => IconActionButtonDark(
          onPressed: () async => _recordNewVideo(context, permissionState),
          child: Icon(
            AbiliaIcons.videoCall,
            size: layout.icon.normal,
            color: AbiliaColors.black,
          ),
        ),
      );

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

class EditChecklistWidget extends StatelessWidget {
  const EditChecklistWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          child: Container(
            decoration: whiteBoxDecoration,
            child: BlocProvider(
              create: (context) => EditChecklistCubit(
                context.read<EditActivityCubit>(),
              ),
              child: Column(
                children: <Widget>[
                  const Expanded(child: EditChecklistView()),
                  Divider(indent: layout.checklist.listPadding.left),
                  Padding(
                    padding: layout.checklist.addNewQButtonPadding,
                    child: const AddNewQuestionButton(),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}

class AddNewQuestionButton extends StatelessWidget {
  const AddNewQuestionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return Tts.data(
      data: translate.addNew,
      child: RawMaterialButton(
        constraints: BoxConstraints(
          minHeight: layout.checklist.question.viewHeight,
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AbiliaColors.green140),
          borderRadius: borderRadius,
        ),
        fillColor: AbiliaColors.green,
        elevation: 0,
        disabledElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        hoverElevation: 0,
        onPressed: () async => _handleNewQuestion(context),
        child: Row(
          children: [
            Padding(
              padding: layout.checklist.addNewQIconPadding,
              child: Icon(
                AbiliaIcons.newIcon,
                size: layout.icon.small,
                color: AbiliaColors.white,
              ),
            ),
            Text(
              translate.addNew,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AbiliaColors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNewQuestion(BuildContext context) async {
    final editChecklistCubit = context.read<EditChecklistCubit>();
    final result = await showAbiliaBottomSheet<ImageAndName>(
      context: context,
      providers: copiedAuthProviders(context),
      child: const EditQuestionBottomSheet(),
      routeSettings: (EditQuestionBottomSheet).routeSetting(),
    );

    if (result != null && result.isNotEmpty) {
      editChecklistCubit.newQuestion(result);
    }
  }
}

class EditNoteWidget extends StatelessWidget {
  final NoteInfoItem infoItem;

  const EditNoteWidget({
    required this.infoItem,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: () async => editText(context, infoItem),
          child: Container(
            decoration: whiteBoxDecoration,
            child: NoteBlock(
              text: infoItem.text,
              textWidget: infoItem.text.isEmpty
                  ? Text(
                      Lt.of(context).typeSomething,
                      style: abiliaTextTheme.bodyLarge
                          ?.copyWith(color: const Color(0xff747474)),
                    )
                  : Text(infoItem.text),
            ),
          ),
        ),
      );

  Future editText(
    BuildContext context,
    NoteInfoItem infoItem,
  ) async {
    final authProviders = copiedAuthProviders(context);
    final editActivityCubit = context.read<EditActivityCubit>();
    final result = await Navigator.of(context).push<String>(
      PersistentPageRouteBuilder(
        pageBuilder: (_, __, ___) => MultiBlocProvider(
          providers: authProviders,
          child: EditNotePage(text: infoItem.text),
        ),
        settings: (EditNotePage).routeSetting(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        ),
      ),
    );
    if (result != null && result != infoItem.text) {
      editActivityCubit.replaceActivity(
        editActivityCubit.state.activity.copyWith(
          infoItem: NoteInfoItem(result),
        ),
      );
    }
  }
}

class AddVideoWidget extends StatelessWidget {
  final VideoInfoItem infoItem;

  const AddVideoWidget({
    required this.infoItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: layout.activityPage.youtubePlayerPadding,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: VideoPlayer(
              isEditActivity: true,
              fileId: infoItem.fileId,
            ),
          ),
        ),
      );
}
