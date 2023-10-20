import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/bloc/activities/edit_activity/edit_activity_cubit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class EditNoteWidget extends StatelessWidget {
  final NoteInfoItem infoItem;

  const EditNoteWidget({
    required this.infoItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (infoItem.text.isEmpty) await _openEditText(context);
    });
    return Expanded(
      child: GestureDetector(
        onTap: () async => _openEditText(context),
        child: NoteBlock(text: infoItem.text),
      ),
    );
  }

  Future<void> _openEditText(BuildContext context) async {
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
    if (result != null && result != infoItem.text && result.isNotEmpty) {
      return editActivityCubit.replaceActivity(
        editActivityCubit.state.activity.copyWith(
          infoItem: NoteInfoItem(result),
        ),
      );
    }
    if (result == null && infoItem.text.isEmpty && context.mounted) {
      context.read<EditActivityCubit>().removeInfoItem();
    }
  }
}

class NoteBlock extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final ScrollController? scrollController;

  const NoteBlock({
    super.key,
    this.text = '',
    this.textStyle,
    this.scrollController,
  });

  @override
  State createState() => _NoteBlockState();
}

class _NoteBlockState extends State<NoteBlock> {
  late final ScrollController controller;
  late final TextStyle textStyle;

  @override
  void initState() {
    super.initState();
    controller = widget.scrollController ?? ScrollController();
    textStyle = widget.textStyle ?? bodyLarge;
  }

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data: widget.text,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return DefaultTextStyle(
            style: textStyle,
            child: ScrollArrows.vertical(
              controller: controller,
              child: SingleChildScrollView(
                padding: layout.note.notePadding,
                controller: controller,
                child: Stack(
                  children: [
                    Lines(
                      textRenderingSize: widget.text.calculateTextRenderSize(
                        constraints: constraints,
                        textStyle: textStyle,
                        padding: layout.note.notePadding,
                        textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      ),
                    ),
                    Text(widget.text),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Lines extends StatelessWidget {
  final TextRenderingSize textRenderingSize;

  const Lines({
    required this.textRenderingSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final offset = layout.note.lineOffset;
    final line = Padding(
      padding: EdgeInsets.only(
        top: textRenderingSize.textPainter.preferredLineHeight - offset,
        bottom: offset,
      ),
      child: const Divider(endIndent: 0),
    );

    return Column(
      children: List.generate(textRenderingSize.numberOfLines, (_) => line),
    );
  }
}
