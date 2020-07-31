import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class EditActivityPage extends StatelessWidget {
  final DateTime day;
  final String title;
  const EditActivityPage({
    @required this.day,
    this.title = '',
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) {
        final fullDay = state.activity.fullDay;
        return DefaultTabController(
          initialIndex: 0,
          length: 3 + (fullDay ? 0 : 1),
          child: Scaffold(
            appBar: AbiliaAppBar(
              bottom: AbiliaTabBar(
                collapsedCondition: (i) {
                  switch (i) {
                    case 1:
                      return fullDay;
                    default:
                      return false;
                  }
                },
                tabs: <Widget>[
                  Icon(AbiliaIcons.my_photos),
                  Icon(AbiliaIcons.attention),
                  Icon(AbiliaIcons.repeat),
                  Icon(AbiliaIcons.attachment),
                ],
              ),
              title: title,
              trailing: Builder(
                  builder: (context) => ActionButton(
                      key: TestKey.finishEditActivityButton,
                      child: Icon(AbiliaIcons.ok, size: 32),
                      onPressed: () => _finishedPressed(context, state))),
            ),
            body: TabBarView(children: [
              MainTab(state: state, day: day),
              if (!fullDay) AlarmAndReminderTab(activity: state.activity),
              UnderConstruction(),
              InfoItemTab(state: state),
            ]),
          ),
        );
      },
    );
  }

  Future _finishedPressed(BuildContext context, EditActivityState state) async {
    if (state.canSave) {
      if (state is StoredActivityState && state.activity.isRecurring) {
        final applyTo = await showViewDialog<ApplyTo>(
          context: context,
          builder: (context) => EditRecurrentDialog(),
        );
        if (applyTo == null) return;
        BlocProvider.of<EditActivityBloc>(context)
            .add(SaveRecurringActivity(applyTo, state.day));
      } else {
        BlocProvider.of<EditActivityBloc>(context).add(SaveActivity());
      }
      await Navigator.of(context).maybePop();
    } else {
      _scrollToStart(context);
      final translate = Translator.of(context).translate;

      BlocProvider.of<EditActivityBloc>(context).add(SaveActivity());
      if (!state.hasTitleOrImage && !state.hasStartTime) {
        await showErrorViewDialog(
          translate.missingTitleOrImageAndStartTime,
          context: context,
        );
      } else if (!state.hasTitleOrImage) {
        await showErrorViewDialog(
          translate.missingTitleOrImage,
          context: context,
        );
      } else {
        await showErrorViewDialog(
          translate.missingStartTime,
          context: context,
        );
      }
    }
  }

  void _scrollToStart(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    if (tabController.index != 0) {
      tabController.animateTo(0);
    } else {
      final scrollController = PrimaryScrollController.of(context);
      if (scrollController != null) {
        scrollController.animateTo(0.0,
            duration: kTabScrollDuration, curve: Curves.ease);
      }
    }
  }
}

class UnderConstruction extends StatelessWidget {
  final BannerLocation bannerLocation;
  const UnderConstruction({this.bannerLocation = BannerLocation.topStart});
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      alignment: _alignment,
      scale: 3,
      child: Banner(
        location: bannerLocation,
        color: AbiliaColors.red,
        message: 'Under construction',
      ),
    );
  }

  Alignment get _alignment {
    switch (bannerLocation) {
      case BannerLocation.topStart:
        return Alignment.topLeft;
      case BannerLocation.topEnd:
        return Alignment.topRight;
      case BannerLocation.bottomStart:
        return Alignment.bottomLeft;
      case BannerLocation.bottomEnd:
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }
}

class MainTab extends StatelessWidget with EditActivityTab {
  const MainTab({
    Key key,
    @required this.state,
    @required this.day,
  }) : super(key: key);

  final EditActivityState state;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final activity = state.activity;
    return ListView(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 56.0),
      children: <Widget>[
        separated(NameAndPictureWidget(state)),
        separated(DateAndTimeWidget(state)),
        CollapsableWidget(
          child: separated(CategoryWidget(activity)),
          collapsed: activity.fullDay,
        ),
        separated(CheckableAndDeleteAfterWidget(activity)),
        padded(AvailibleForWidget(activity)),
      ],
    );
  }
}

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  const AlarmAndReminderTab({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: <Widget>[
          separated(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SubHeading(Translator.of(context).translate.reminders),
                ReminderSwitch(activity: activity),
                CollapsableWidget(
                  padding: const EdgeInsets.only(top: 8.0),
                  collapsed:
                      activity.fullDay || activity.reminderBefore.isEmpty,
                  child: Reminders(activity: activity),
                ),
              ],
            ),
          ),
          padded(
            AlarmWidget(activity),
          ),
        ],
      ),
    );
  }
}

class InfoItemTab extends StatelessWidget with EditActivityTab {
  InfoItemTab({
    Key key,
    @required this.state,
  }) : super(key: key);

  final EditActivityState state;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final activity = state.activity;
    final infoItem = activity.infoItem;

    Future onTap() async {
      final result = await showViewDialog<Type>(
        context: context,
        builder: (context) => SelectInfoTypeDialog(
          infoItemType: activity.infoItem.runtimeType,
        ),
      );
      if (result != null) {
        BlocProvider.of<EditActivityBloc>(context)
            .add(ChangeInfoItemType(result));
      }
    }

    return padded(
      Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SubHeading(translate.infoType),
            if (infoItem is NoteInfoItem) ...[
              PickField(
                leading: Icon(AbiliaIcons.edit),
                label: Text(translate.infoTypeNote),
                onTap: onTap,
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () async {
                  final result = await showViewDialog<String>(
                    context: context,
                    builder: (context) => EditNoteDialog(text: infoItem.text),
                  );
                  if (result != null && result != infoItem.text) {
                    BlocProvider.of<EditActivityBloc>(context).add(
                        ReplaceActivity(
                            activity.copyWith(infoItem: NoteInfoItem(result))));
                  }
                },
                child: Container(
                  constraints: BoxConstraints.loose(Size.fromHeight(318.0)),
                  decoration: whiteBoxDecoration,
                  child: NoteBlock(
                    text: infoItem.text,
                    child: infoItem.text.isEmpty
                        ? Text(
                            Translator.of(context).translate.typeSomething,
                            style: abiliaTextTheme.bodyText1
                                .copyWith(color: const Color(0xff747474)),
                          )
                        : Text(infoItem.text),
                  ),
                ),
              ),
            ] else if (infoItem is Checklist) ...[
              PickField(
                leading: Icon(AbiliaIcons.ok),
                label: Text(translate.infoTypeChecklist),
                onTap: onTap,
              ),
              UnderConstruction(),
            ] else
              PickField(
                leading: Icon(AbiliaIcons.information),
                label: Text(translate.infoTypeNone),
                onTap: onTap,
              ),
          ],
        ),
      ),
    );
  }
}

mixin EditActivityTab {
  Widget separated(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AbiliaColors.white120),
        ),
      ),
      child: padded(child),
    );
  }

  Widget padded(Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 24.0, 4.0, 16.0),
      child: child,
    );
  }
}
