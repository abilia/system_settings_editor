import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ChecklistView extends StatelessWidget {
  final Checklist checklist;
  final DateTime? day;
  final Function(Question)? onTap;
  final bool preview;

  const ChecklistView(
    this.checklist, {
    this.day,
    this.onTap,
    Key? key,
  })  : preview = day == null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return ScrollArrows.vertical(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        padding: layout.templates.s2.withoutBottom,
        itemCount: checklist.questions.length,
        itemBuilder: (context, i) {
          final day = this.day;
          final question = checklist.questions[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: layout.formPadding.verticalItemDistance,
            ),
            child: QuestionView(
              question,
              onTap: onTap,
              signedOff: day != null && checklist.isSignedOff(question, day),
              inactive: preview,
            ),
          );
        },
      ),
    );
  }
}

class EditChecklistWidget extends StatelessWidget {
  const EditChecklistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditChecklistCubit(
        context.read<EditActivityCubit>(),
      ),
      child: Builder(builder: (context) {
        final scrollController = ScrollController();
        final checklist =
            context.select((EditChecklistCubit cubit) => cubit.state.checklist);
        return BlocListener<EditChecklistCubit, EditChecklistState>(
          listenWhen: (previous, current) =>
              previous.checklist.questions.isNotEmpty &&
              current.checklist.questions.isEmpty,
          listener: (context, state) =>
              context.read<EditActivityCubit>().removeInfoItem(),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: ScrollArrows.vertical(
                    controller: scrollController,
                    verticalOverflowDivider: true,
                    overflowDividerPadding: layout.templates.m6.onlyHorizontal,
                    child: ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      padding: layout.templates.m6.onlyHorizontal,
                      itemCount: checklist.questions.length,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(
                          bottom: i < checklist.questions.length - 1
                              ? layout.formPadding.verticalItemDistance
                              : 0,
                        ),
                        child: EditQuestionView(checklist.questions[i]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: layout.templates.m6.onlyVertical.onlyTop.add(
                    layout.templates.m6.onlyHorizontal,
                  ),
                  child: _AddNewQuestionButton(
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AddNewQuestionButton extends StatelessWidget {
  final ScrollController scrollController;

  const _AddNewQuestionButton({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    _openNewQuestionOnEmpty(context);
    return Tts.data(
      data: translate.newTask,
      child: IconAndTextButton(
        style: actionButtonStyleBlack.copyWith(minimumSize: denseSize),
        icon: AbiliaIcons.plus,
        text: translate.newTask,
        iconSize: layout.icon.smaller,
        onPressed: () async => _handleNewQuestion(context),
      ),
    );
  }

  void _openNewQuestionOnEmpty(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final checklistCubit = context.read<EditChecklistCubit>();
      final checklist = checklistCubit.state.checklist;
      if (checklist.questions.isEmpty) {
        await _handleNewQuestion(context);
      }
    });
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
      return scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
    if (context.mounted &&
        editChecklistCubit.state.checklist.questions.isEmpty) {
      context.read<EditActivityCubit>().removeInfoItem();
    }
  }
}

class EditQuestionView extends StatelessWidget {
  final Question question;

  const EditQuestionView(
    this.question, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditChecklistCubit, EditChecklistState>(
      builder: (context, state) {
        final selected = state.selected == question;
        return Stack(
          children: [
            QuestionView(
              question,
              onTap: context.read<EditChecklistCubit>().select,
              selected: selected,
              inactive: true,
            ),
            if (selected)
              Positioned.fill(
                child: SortableToolbar(
                  disableUp: state.disableUp,
                  disableDown: state.disableDown,
                  onTapEdit: () async => _editQuestion(question, context),
                  onTapDelete: context.read<EditChecklistCubit>().delete,
                  onTapReorder: context.read<EditChecklistCubit>().reorder,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _editQuestion(
    Question oldQuestion,
    BuildContext context,
  ) async {
    final editChecklistCubit = context.read<EditChecklistCubit>();
    final result = await showAbiliaBottomSheet<ImageAndName>(
      context: context,
      providers: copiedAuthProviders(context),
      child: EditQuestionBottomSheet(
        question: oldQuestion,
      ),
      routeSettings: (EditQuestionBottomSheet).routeSetting(),
    );
    if (result != null) {
      editChecklistCubit.edit(result);
    }
  }
}

class QuestionView extends StatelessWidget {
  final Question question;
  final void Function(Question)? onTap;
  final bool signedOff, inactive, selected;

  const QuestionView(
    this.question, {
    this.onTap,
    this.signedOff = false,
    this.inactive = false,
    this.selected = false,
    Key? key,
  }) : super(key: key);

  static const duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final selectedTheme = theme.copyWith(
      textTheme: textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AbiliaColors.white140,
          decoration: TextDecoration.lineThrough,
        ),
      ),
    );
    final onTap = this.onTap;

    return Tts.fromSemantics(
      SemanticsProperties(checked: question.checked, label: question.name),
      child: AnimatedTheme(
        data: signedOff ? selectedTheme : theme,
        duration: duration,
        child: Builder(
          builder: (context) => Material(
            type: MaterialType.transparency,
            borderRadius: borderRadius,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onTap != null ? () => onTap(question) : null,
              child: AnimatedContainer(
                constraints: BoxConstraints(
                    minHeight: layout.checklist.question.viewHeight),
                duration: duration,
                decoration: signedOff
                    ? boxDecoration.copyWith(
                        border: Border.all(style: BorderStyle.none))
                    : selected
                        ? greySelectedBoxDecoration
                        : boxDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    if (question.hasImage)
                      InkWell(
                        borderRadius: borderRadius,
                        onTap: () async => _showImage(
                          question.fileId,
                          question.image,
                          context,
                        ),
                        child: Padding(
                          padding: layout.checklist.question.imagePadding,
                          child: AnimatedOpacity(
                            duration: duration,
                            opacity: signedOff ? 0.5 : 1.0,
                            child: FadeInCalendarImage(
                              imageFile: AbiliaFile.from(
                                id: question.fileId,
                                path: question.image,
                              ),
                              width: layout.checklist.question.imageSize,
                              height: layout.checklist.question.imageSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    if (question.hasTitle)
                      Expanded(
                        child: Padding(
                          padding: layout.checklist.question.titlePadding,
                          child: Text(
                            question.name,
                            style: layout.checklist.question.textStyle.copyWith(
                              decoration: signedOff //
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    if (!inactive)
                      IconTheme(
                        data: Theme.of(context)
                            .iconTheme
                            .copyWith(size: layout.icon.small),
                        child: Padding(
                          padding: layout.checklist.question.iconPadding,
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
    );
  }

  Future<void> _showImage(
      String fileId, String filePath, BuildContext context) async {
    await showViewDialog<bool>(
      useSafeArea: false,
      context: context,
      builder: (_) {
        return FullscreenImageDialog(
          fileId: fileId,
          filePath: filePath,
        );
      },
      routeSettings: (FullscreenImageDialog).routeSetting(),
    );
  }
}
