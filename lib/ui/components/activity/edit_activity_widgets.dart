import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityNameAndPictureWidget extends StatelessWidget {
  final EditActivityState state;
  const ActivityNameAndPictureWidget(this.state, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NameAndPictureWidget(
      selectedImage: state.selectedImage,
      errorState: state.saveErrors.contains(SaveError.NO_TITLE_OR_IMAGE),
      text: state.activity.title,
      inputFormatters: [LengthLimitingTextInputFormatter(50)],
      onImageSelected: (selectedImage) {
        BlocProvider.of<EditActivityBloc>(context).add(
          ImageSelected(selectedImage),
        );
      },
      onTextEdit: (text) {
        if (state.activity.title != text) {
          BlocProvider.of<EditActivityBloc>(context)
              .add(ReplaceActivity(state.activity.copyWith(title: text)));
        }
      },
    );
  }
}

class NameAndPictureWidget extends StatelessWidget {
  final SelectedImage selectedImage;
  final void Function(SelectedImage) onImageSelected;
  final void Function(String) onTextEdit;
  final bool errorState;
  final String text;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;

  const NameAndPictureWidget({
    Key key,
    this.selectedImage,
    this.onImageSelected,
    this.onTextEdit,
    this.errorState = false,
    this.maxLines = 1,
    this.inputFormatters = const <TextInputFormatter>[],
    this.text,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectPictureWidget(
            selectedImage: selectedImage,
            onImageSelected: onImageSelected,
            errorState: errorState,
          ),
          SizedBox(width: 12.s),
          Expanded(
            child: NameInput(
              text: text,
              onEdit: onTextEdit,
              errorState: errorState,
              maxLines: maxLines,
              inputFormatters: inputFormatters,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectPictureWidget extends StatelessWidget {
  static final imageSize = 84.0.s, padding = 4.0.s;
  final SelectedImage selectedImage;

  final void Function(SelectedImage) onImageSelected;
  final bool errorState;

  const SelectPictureWidget({
    Key key,
    @required this.selectedImage,
    @required this.onImageSelected,
    this.errorState = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heading = Translator.of(context).translate.picture;
    return Tts.fromSemantics(
      SemanticsProperties(button: true, label: heading),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SubHeading(heading),
          SelectedImageWidget(
            errorState: errorState,
            onTap: () => imageClick(context),
            selectedImage: selectedImage,
          ),
        ],
      ),
    );
  }

  void imageClick(BuildContext context) async {
    final newSelectedImage = await Navigator.of(context).push<SelectedImage>(
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: SelectPicturePage(selectedImage: selectedImage),
        ),
      ),
    );

    if (newSelectedImage != null) {
      if (newSelectedImage.toBeStored) {
        BlocProvider.of<UserFileBloc>(context).add(
          ImageAdded(newSelectedImage),
        );
        BlocProvider.of<SortableBloc>(context).add(
          ImageArchiveImageAdded(
            newSelectedImage.id,
            newSelectedImage.file.path,
          ),
        );
      }
      onImageSelected?.call(newSelectedImage);
    }
  }
}

class SelectedImageWidget extends StatelessWidget {
  final GestureTapCallback onTap;
  final SelectedImage selectedImage;

  final bool errorState;

  static final innerSize =
      SelectPictureWidget.imageSize - SelectPictureWidget.padding * 2;

  const SelectedImageWidget({
    Key key,
    @required this.selectedImage,
    this.errorState = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SelectPictureWidget.imageSize,
      height: SelectPictureWidget.imageSize,
      child: LinedBorder(
        key: TestKey.addPicture,
        padding: EdgeInsets.all(SelectPictureWidget.padding),
        errorState: errorState,
        onTap: onTap,
        child: selectedImage.isNotEmpty
            ? FadeInCalendarImage(
                height: innerSize,
                width: innerSize,
                imageFileId: selectedImage.id,
                imageFilePath: selectedImage.path,
                imageFile: selectedImage.file,
              )
            : Container(
                decoration: whiteNoBorderBoxDecoration,
                width: innerSize,
                height: innerSize,
                child: Icon(
                  AbiliaIcons.add_photo,
                  size: defaultIconSize,
                  color: AbiliaColors.black75,
                ),
              ),
      ),
    );
  }
}

class NameInput extends StatefulWidget {
  const NameInput({
    Key key,
    @required this.text,
    this.onEdit,
    this.errorState = false,
    this.maxLines = 1,
    this.inputFormatters = const <TextInputFormatter>[],
  }) : super(key: key);

  final String text;
  final Function(String) onEdit;
  final bool errorState;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;

  @override
  _NameInputState createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.text);
    _nameController.addListener(_onEdit);
  }

  void _onEdit() {
    widget.onEdit(_nameController.text);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onEdit);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbiliaTextInput(
      formKey: TestKey.editTitleTextFormField,
      controller: _nameController,
      errorState: widget.errorState,
      icon: AbiliaIcons.edit,
      heading: Translator.of(context).translate.name,
      inputHeading: Translator.of(context).translate.name,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final Activity activity;

  const CategoryWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(translator.category),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildCategoryRadioField(
                  context,
                  Category.left,
                  state.leftCategoryName ??
                      Translator.of(context).translate.left,
                ),
                SizedBox(width: 8.s),
                buildCategoryRadioField(
                  context,
                  Category.right,
                  state.rightCategoryName ??
                      Translator.of(context).translate.right,
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Expanded buildCategoryRadioField(
      BuildContext context, int category, String text) {
    final left = category == Category.left;
    final key = left ? TestKey.leftCategoryRadio : TestKey.rightCategoryRadio;
    final icon =
        left ? AbiliaIcons.move_item_left : AbiliaIcons.move_item_right;
    return Expanded(
      child: RadioField(
        key: key,
        margin: EdgeInsets.symmetric(horizontal: 14.0.s, vertical: 16.0.s),
        onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
            .add(ReplaceActivity(activity.copyWith(category: v))),
        leading: Icon(icon),
        text: Text(
          text,
          overflow: TextOverflow.ellipsis,
        ),
        groupValue: activity.category,
        value: category,
      ),
    );
  }
}

class AlarmWidget extends StatelessWidget {
  final Activity activity;

  const AlarmWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    final alarm = activity.alarm;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SubHeading(translator.alarm),
          PickField(
            key: TestKey.selectAlarm,
            leading: Icon(alarm.iconData()),
            text: Text(alarm.text(translator)),
            onTap: memoSettingsState.abilityToSelectAlarm
                ? () async {
                    final result = await Navigator.of(context)
                        .push<AlarmType>(MaterialPageRoute(
                      builder: (_) => CopiedAuthProviders(
                        blocContext: context,
                        child: SelectAlarmTypePage(
                          alarm: alarm.typeSeagull,
                        ),
                      ),
                      settings: RouteSettings(name: 'SelectAlarmTypePage'),
                    ));
                    if (result != null) {
                      BlocProvider.of<EditActivityBloc>(context).add(
                          ReplaceActivity(activity.copyWith(
                              alarm: activity.alarm.copyWith(type: result))));
                    }
                  }
                : null,
          ),
          SizedBox(height: 8.0.s),
          AlarmOnlyAtStartSwitch(
            alarm: alarm,
            onChanged: (v) => BlocProvider.of<EditActivityBloc>(context).add(
              ReplaceActivity(
                activity.copyWith(alarm: alarm.copyWith(onlyStart: v)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmOnlyAtStartSwitch extends StatelessWidget {
  const AlarmOnlyAtStartSwitch({
    Key key,
    @required this.alarm,
    @required this.onChanged,
  }) : super(key: key);

  final Alarm alarm;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchField(
        key: TestKey.alarmAtStartSwitch,
        leading: Icon(
          AbiliaIcons.handi_alarm,
          size: smallIconSize,
        ),
        text: Text(Translator.of(context).translate.alarmOnlyAtStartTime),
        value: alarm.onlyStart,
        onChanged: alarm.shouldAlarm ? onChanged : null,
      );
}

class CheckableAndDeleteAfterWidget extends StatelessWidget {
  final Activity activity;

  const CheckableAndDeleteAfterWidget(this.activity, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SwitchField(
          key: TestKey.checkableSwitch,
          leading: Icon(
            AbiliaIcons.handi_check,
            size: smallIconSize,
          ),
          text: Text(translator.checkable),
          value: activity.checkable,
          onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
              .add(ReplaceActivity(activity.copyWith(checkable: v))),
        ),
        SizedBox(height: 8.0.s),
        SwitchField(
          key: TestKey.deleteAfterSwitch,
          leading: Icon(
            AbiliaIcons.delete_all_clear,
            size: smallIconSize,
          ),
          text: Text(translator.deleteAfter),
          value: activity.removeAfter,
          onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
              .add(ReplaceActivity(activity.copyWith(removeAfter: v))),
        ),
      ],
    );
  }
}

class AvailableForWidget extends StatelessWidget {
  final Activity activity;

  const AvailableForWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final secret = activity.secret;
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.availableFor),
        PickField(
          key: TestKey.availibleFor,
          leading: Icon(
            secret ? AbiliaIcons.password_protection : AbiliaIcons.user_group,
          ),
          text:
              Text(secret ? translator.onlyMe : translator.meAndSupportPersons),
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AvailableForPage(secret: activity.secret),
              ),
            );
            if (result != null) {
              BlocProvider.of<EditActivityBloc>(context)
                  .add(ReplaceActivity(activity.copyWith(secret: result)));
            }
          },
        ),
      ],
    );
  }
}

class RecurrenceWidget extends StatelessWidget {
  final EditActivityState state;

  const RecurrenceWidget(this.state, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    final activity = state.activity;
    final recurrentType = activity.recurs.recurrance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.recurrence),
        PickField(
          key: TestKey.changeRecurrence,
          leading: Icon(recurrentType.iconData()),
          text: Text(recurrentType.text(translator)),
          onTap: () async {
            final result = await Navigator.of(context)
                .push<RecurrentType>(MaterialPageRoute(
              builder: (_) => SelectRecurrencePage(
                recurrentType: recurrentType,
              ),
              settings: RouteSettings(name: 'SelectRecurrencePage'),
            ));
            if (result != null) {
              if (state.storedRecurring &&
                  result == state.originalActivity.recurs.recurrance) {
                BlocProvider.of<EditActivityBloc>(context).add(
                  ReplaceActivity(
                    activity.copyWith(
                      recurs: state.originalActivity.recurs,
                    ),
                  ),
                );
              } else {
                final recurentType = _newType(
                  result,
                  state.timeInterval.startDate,
                );
                BlocProvider.of<EditActivityBloc>(context).add(
                  ReplaceActivity(
                    activity.copyWith(
                      recurs: recurentType,
                    ),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Recurs _newType(RecurrentType type, DateTime startdate) {
    switch (type) {
      case RecurrentType.weekly:
        return Recurs.weeklyOnDay(startdate.weekday);
      case RecurrentType.monthly:
        return Recurs.monthly(startdate.day);
      case RecurrentType.yearly:
        return Recurs.yearly(startdate);
      default:
        return Recurs.not;
    }
  }
}

class EndDateWidget extends StatelessWidget {
  final EditActivityState state;
  bool get disabled => state.storedRecurring;

  const EndDateWidget(this.state, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final activity = state.activity;
    final translate = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CollapsableWidget(
          collapsed: activity.recurs.hasNoEnd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubHeading(translate.endDate),
              DatePicker(
                activity.recurs.end,
                firstDate: state.timeInterval.startDate,
                onChange: disabled
                    ? null
                    : (newDate) =>
                        BlocProvider.of<EditActivityBloc>(context).add(
                          ReplaceActivity(
                            activity.copyWith(
                              recurs: activity.recurs.changeEnd(newDate),
                            ),
                          ),
                        ),
              ),
              SizedBox(
                height: 16.0,
              ),
            ],
          ),
        ),
        SwitchField(
          key: TestKey.noEndDate,
          leading: Icon(
            AbiliaIcons.basic_activity,
            size: smallIconSize,
          ),
          text: Text(translate.noEndDate),
          value: activity.recurs.hasNoEnd,
          onChanged: disabled
              ? null
              : (v) => BlocProvider.of<EditActivityBloc>(context).add(
                    ReplaceActivity(
                      activity.copyWith(
                        recurs: activity.recurs.changeEnd(
                          v ? Recurs.noEndDate : activity.startTime,
                        ),
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}

class WeekDays extends StatelessWidget {
  final Set<int> selectedWeekDays;
  const WeekDays(
    this.selectedWeekDays, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14.0.s,
      runSpacing: 8.0.s,
      children: List.generate(DateTime.daysPerWeek, (i) {
        final d = i + 1;
        return SelectableField(
          text: Text(
            Translator.of(context).translate.shortWeekday(d),
            style: Theme.of(context).textTheme.bodyText1.copyWith(height: 1.5),
          ),
          selected: selectedWeekDays.contains(d),
          onTap: () =>
              context.read<RecurringWeekBloc>().add(AddOrRemoveWeekday(d)),
        );
      }),
    );
  }
}

class MonthDays extends StatelessWidget {
  final Activity activity;

  const MonthDays(
    this.activity, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final selectedMonthDays = activity.recurs.monthDays;
    return Wrap(
      spacing: 14.0.s,
      runSpacing: 8.0.s,
      children: List.generate(31, (i) {
        final d = i + 1;
        return SelectableField(
            text: Text(
              '$d',
              style:
                  Theme.of(context).textTheme.bodyText1.copyWith(height: 1.5),
            ),
            selected: selectedMonthDays.contains(d),
            onTap: () {
              if (!selectedMonthDays.add(d)) {
                selectedMonthDays.remove(d);
              }
              BlocProvider.of<EditActivityBloc>(context).add(
                ReplaceActivity(
                  activity.copyWith(
                      recurs: Recurs.monthlyOnDays(selectedMonthDays,
                          ends: activity.recurs.end)),
                ),
              );
            });
      }),
    );
  }
}
