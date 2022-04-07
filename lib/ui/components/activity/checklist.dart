import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ChecklistView extends StatefulWidget {
  final Checklist checklist;
  final DateTime? day;
  final Function(Question)? onTap, onTapEdit, onTapDelete;
  final Function(Question, SortableReorderDirection)? onTapReorder;
  final EdgeInsetsGeometry padding;
  final bool preview, hasToolbar;

  const ChecklistView(
    this.checklist, {
    this.day,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.preview = false,
    Key? key,
  })  : hasToolbar = false,
        onTapEdit = null,
        onTapDelete = null,
        onTapReorder = null,
        super(key: key);

  const ChecklistView.withToolbar(
    this.checklist, {
    this.day,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapReorder,
    this.padding = EdgeInsets.zero,
    this.preview = false,
    Key? key,
  })  : hasToolbar = true,
        onTap = null,
        assert(onTapEdit != null && onTapDelete != null && onTapReorder != null,
            'All callbacks must be non null'),
        super(key: key);

  @override
  _ChecklistViewState createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  late final ScrollController _controller;
  int? selectedQuestion;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollArrows.vertical(
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        padding: widget.padding,
        itemCount: widget.checklist.questions.length,
        itemBuilder: (context, i) {
          final question = widget.checklist.questions[i];
          final day = widget.day;
          return Stack(
            children: [
              QuestionView(
                question,
                inactive: widget.preview,
                signedOff:
                    day != null && widget.checklist.isSignedOff(question, day),
                onTap: widget.onTap != null
                    ? () => widget.onTap?.call(question)
                    : widget.hasToolbar
                        ? () => setState(() {
                              selectedQuestion =
                                  selectedQuestion == i ? null : i;
                            })
                        : null,
              ),
              if (widget.hasToolbar && selectedQuestion == i)
                Positioned.fill(
                  child: SortableToolbar(
                    disableUp: i == 0,
                    disableDown: i == widget.checklist.questions.length - 1,
                    margin: layout.checkList.questionViewPadding,
                    onTapEdit: () {
                      _deselectQuestion();
                      widget.onTapEdit?.call(question);
                    },
                    onTapDelete: () {
                      _deselectQuestion();
                      widget.onTapDelete?.call(question);
                    },
                    onTapReorder: (direction) {
                      widget.onTapReorder?.call(question, direction);
                      final selectedIndex = selectedQuestion;

                      if (widget.onTapReorder != null &&
                          selectedIndex != null) {
                        final newSelectedIndex =
                            direction == SortableReorderDirection.up
                                ? selectedIndex - 1
                                : selectedIndex + 1;
                        if (newSelectedIndex >= 0 &&
                            newSelectedIndex <
                                widget.checklist.questions.length) {
                          selectedQuestion = newSelectedIndex;
                        }
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _deselectQuestion() {
    setState(() => selectedQuestion = null);
  }
}

class QuestionView extends StatelessWidget {
  final Question question;
  final bool signedOff;
  final GestureTapCallback? onTap;
  final bool inactive;

  const QuestionView(
    this.question, {
    this.onTap,
    this.signedOff = false,
    this.inactive = false,
    Key? key,
  }) : super(key: key);

  static const duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final selectedTheme = theme.copyWith(
      textTheme: textTheme.copyWith(
        bodyText1: textTheme.bodyText1?.copyWith(
          color: AbiliaColors.white140,
          decoration: TextDecoration.lineThrough,
        ),
      ),
    );

    return Tts.fromSemantics(
      SemanticsProperties(
        checked: question.checked,
        label: question.name,
      ),
      child: AnimatedTheme(
        data: signedOff ? selectedTheme : theme,
        duration: duration,
        child: Builder(
          builder: (context) => Padding(
            padding: layout.checkList.questionViewPadding,
            child: Material(
              type: MaterialType.transparency,
              borderRadius: borderRadius,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: onTap,
                child: AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: layout.checkList.questionViewHeight),
                  duration: duration,
                  decoration: signedOff
                      ? boxDecoration.copyWith(
                          border: Border.all(style: BorderStyle.none))
                      : boxDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      if (question.hasImage)
                        InkWell(
                          borderRadius: borderRadius,
                          onTap: () => _showImage(
                            question.fileId,
                            question.image,
                            context,
                          ),
                          child: Padding(
                            padding: layout.checkList.questionImagePadding,
                            child: AnimatedOpacity(
                              duration: duration,
                              opacity: signedOff ? 0.5 : 1.0,
                              child: FadeInCalendarImage(
                                key: TestKey.checklistQuestionImageKey,
                                imageFile: AbiliaFile.from(
                                  id: question.fileId,
                                  path: question.image,
                                ),
                                width: layout.checkList.questionImageSize,
                                height: layout.checkList.questionImageSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      if (question.hasTitle)
                        Expanded(
                          child: Padding(
                            padding: layout.checkList.questionTitlePadding,
                            child: Text(
                              question.name,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(height: 1.0),
                            ),
                          ),
                        ),
                      if (!inactive)
                        IconTheme(
                          data: Theme.of(context)
                              .iconTheme
                              .copyWith(size: layout.icon.small),
                          child: Padding(
                            padding: layout.checkList.questionIconPadding,
                            child: AnimatedCrossFade(
                              firstChild: Icon(
                                AbiliaIcons.checkboxSelected,
                                color: inactive
                                    ? AbiliaColors.green40
                                    : AbiliaColors.green,
                              ),
                              secondChild: Icon(
                                AbiliaIcons.checkboxUnselected,
                                color: inactive
                                    ? AbiliaColors.white140
                                    : AbiliaColors.black,
                              ),
                              crossFadeState: signedOff
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              duration: duration,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImage(String fileId, String filePath, BuildContext context) async {
    await showViewDialog<bool>(
      useSafeArea: false,
      context: context,
      builder: (_) {
        return FullscreenImageDialog(
          fileId: fileId,
          filePath: filePath,
        );
      },
    );
  }
}
