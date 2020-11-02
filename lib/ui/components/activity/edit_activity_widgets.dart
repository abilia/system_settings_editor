import 'dart:io';

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
      imageFileId: state.activity.fileId,
      imageFilePath: state.activity.icon,
      errorState: state.saveErrors.contains(SaveError.NO_TITLE_OR_IMAGE),
      text: state.activity.title,
      newImage: state.newImage,
      inputFormatters: [LengthLimitingTextInputFormatter(50)],
      onImageSelected: (selectedImage) {
        BlocProvider.of<EditActivityBloc>(context).add(ImageSelected(
          selectedImage.id,
          selectedImage.path,
          selectedImage.newImage,
        ));
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
  final String imageFileId;
  final String imageFilePath;
  final File newImage;
  final void Function(SelectedImage) onImageSelected;
  final void Function(String) onTextEdit;
  final bool errorState;
  final String text;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;

  const NameAndPictureWidget({
    Key key,
    this.imageFileId,
    this.imageFilePath,
    this.newImage,
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
            imageFileId: imageFileId,
            imageFilePath: imageFilePath,
            newImage: newImage,
            onImageSelected: onImageSelected,
            errorState: errorState,
          ),
          const SizedBox(width: 12),
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

class SelectPictureWidget extends StatefulWidget {
  static const imageSize = 84.0, padding = 4.0;
  final String imageFileId;
  final String imageFilePath;
  final File newImage;
  final void Function(SelectedImage) onImageSelected;
  final bool errorState;

  const SelectPictureWidget({
    Key key,
    @required this.imageFileId,
    @required this.imageFilePath,
    @required this.newImage,
    @required this.onImageSelected,
    @required this.errorState,
  }) : super(key: key);

  @override
  _SelectPictureWidgetState createState() => _SelectPictureWidgetState();
}

class _SelectPictureWidgetState extends State<SelectPictureWidget> {
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
          if ((widget.imageFileId?.isNotEmpty ?? false) ||
              (widget.imageFilePath?.isNotEmpty ?? false))
            InkWell(
              onTap: imageClick,
              child: FadeInCalendarImage(
                height: SelectPictureWidget.imageSize,
                width: SelectPictureWidget.imageSize,
                imageFileId: widget.imageFileId,
                imageFilePath: widget.imageFilePath,
                imageFile: widget.newImage,
              ),
            )
          else
            SizedBox(
              width: SelectPictureWidget.imageSize,
              height: SelectPictureWidget.imageSize,
              child: LinedBorder(
                key: TestKey.addPicture,
                padding: const EdgeInsets.all(SelectPictureWidget.padding),
                errorState: widget.errorState,
                child: Container(
                  decoration: whiteNoBorderBoxDecoration,
                  width: SelectPictureWidget.imageSize -
                      SelectPictureWidget.padding,
                  height: SelectPictureWidget.imageSize -
                      SelectPictureWidget.padding,
                  child: const Icon(
                    AbiliaIcons.add_photo,
                    size: defaultIconSize,
                    color: AbiliaColors.black75,
                  ),
                ),
                onTap: imageClick,
              ),
            ),
        ],
      ),
    );
  }

  void imageClick() async {
    final selectedImage = await showViewDialog<SelectedImage>(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<SortableArchiveBloc<ImageArchiveData>>(
            create: (_) => SortableArchiveBloc<ImageArchiveData>(
              sortableBloc: BlocProvider.of<SortableBloc>(context),
            ),
          ),
          BlocProvider<UserFileBloc>.value(
            value: BlocProvider.of<UserFileBloc>(context),
          ),
        ],
        child: SelectPictureDialog(previousImage: widget.imageFileId),
      ),
    );
    if (selectedImage != null && widget.onImageSelected != null) {
      if (selectedImage.newImage != null) {
        BlocProvider.of<UserFileBloc>(context).add(
          ImageAdded(
            selectedImage.id,
            selectedImage.path,
            selectedImage.newImage,
          ),
        );
        BlocProvider.of<SortableBloc>(context).add(
          ImageArchiveImageAdded(
            selectedImage.id,
            selectedImage.newImage.path,
          ),
        );
      }
      widget.onImageSelected(selectedImage);
    }
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
      heading: Translator.of(context).translate.name,
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
                const SizedBox(width: 8),
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
        onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
            .add(ReplaceActivity(activity.copyWith(category: v))),
        leading: Row(children: <Widget>[
          const SizedBox(width: 6),
          Icon(
            icon,
            size: smallIconSize,
          ),
        ]),
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
            leading: Icon(
              alarm.iconData(),
              size: smallIconSize,
            ),
            text: Text(alarm.text(translator)),
            onTap: memoSettingsState.abilityToSelectAlarm
                ? () async {
                    final result = await showViewDialog<AlarmType>(
                      context: context,
                      builder: (context) => SelectAlarmTypeDialog(
                        alarm: alarm.typeSeagull,
                      ),
                    );
                    if (result != null) {
                      BlocProvider.of<EditActivityBloc>(context).add(
                          ReplaceActivity(activity.copyWith(
                              alarm: activity.alarm.copyWith(type: result))));
                    }
                  }
                : null,
          ),
          const SizedBox(height: 8.0),
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
        const SizedBox(height: 8.0),
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

class AvailibleForWidget extends StatelessWidget {
  final Activity activity;

  const AvailibleForWidget(this.activity, {Key key}) : super(key: key);
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
            size: smallIconSize,
          ),
          text:
              Text(secret ? translator.onlyMe : translator.meAndSupportPersons),
          onTap: () async {
            final result = await showViewDialog<bool>(
              context: context,
              builder: (context) => SelectAvailableForDialog(
                secret: activity.secret,
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
          leading: Icon(
            recurrentType.iconData(),
            size: smallIconSize,
          ),
          text: Text(recurrentType.text(translator)),
          onTap: () async {
            final result = await showViewDialog<RecurrentType>(
              context: context,
              builder: (context) =>
                  SelectRecurrenceDialog(recurrentType: recurrentType),
            );
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
                onChange: (newDate) =>
                    BlocProvider.of<EditActivityBloc>(context).add(
                  ReplaceActivity(
                    activity.copyWith(
                        recurs: activity.recurs.changeEnd(newDate)),
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
          onChanged: (v) => BlocProvider.of<EditActivityBloc>(context).add(
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
      spacing: 14.0,
      runSpacing: 8.0,
      children: List.generate(DateTime.daysPerWeek, (i) {
        final d = i + 1;
        return SelectableField(
          text: Text(
            Translator.of(context).translate.shortWeekday(d),
            style: Theme.of(context).textTheme.bodyText1.copyWith(height: 1.5),
          ),
          selected: selectedWeekDays.contains(d),
          onTap: () =>
              context.bloc<RecurringWeekBloc>().add(AddOrRemoveWeekday(d)),
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
      spacing: 14.0,
      runSpacing: 8.0,
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
