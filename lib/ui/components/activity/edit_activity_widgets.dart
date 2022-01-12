import 'package:flutter/services.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityNameAndPictureWidget extends StatelessWidget {
  const ActivityNameAndPictureWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        return BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
          builder: (context, wizState) {
            return NameAndPictureWidget(
              selectedImage: state.selectedImage,
              errorState:
                  wizState.saveErrors.contains(SaveError.noTitleOrImage),
              text: state.activity.title,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              onImageSelected: (selectedImage) {
                context.read<EditActivityCubit>().imageSelected(
                      selectedImage,
                    );
              },
              onTextEdit: (text) {
                if (state.activity.title != text) {
                  context
                      .read<EditActivityCubit>()
                      .replaceActivity(state.activity.copyWith(title: text));
                }
              },
            );
          },
        );
      },
    );
  }
}

class NameAndPictureWidget extends StatelessWidget {
  final AbiliaFile selectedImage;
  final void Function(AbiliaFile)? onImageSelected;
  final void Function(String)? onTextEdit;
  final bool errorState;
  final String text;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final String? inputHeadingForNameField;

  const NameAndPictureWidget({
    Key? key,
    required this.selectedImage,
    this.onImageSelected,
    this.onTextEdit,
    this.errorState = false,
    this.maxLines = 1,
    this.inputFormatters = const <TextInputFormatter>[],
    required this.text,
    this.inputHeadingForNameField,
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
              inputHeading: inputHeadingForNameField,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectPictureWidget extends StatelessWidget {
  static final imageSize = 84.0.s, padding = 4.0.s;
  final AbiliaFile selectedImage;

  final void Function(AbiliaFile)? onImageSelected;
  final bool errorState;

  const SelectPictureWidget({
    Key? key,
    required this.selectedImage,
    this.onImageSelected,
    this.errorState = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heading = Translator.of(context).translate.picture;
    return Tts.fromSemantics(
      SemanticsProperties(button: true, label: heading),
      child: Column(
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
    final authProviders = copiedAuthProviders(context);
    final newSelectedImage = await Navigator.of(context).push<AbiliaFile>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: SelectPicturePage(
            selectedImage: selectedImage,
          ),
        ),
      ),
    );

    if (newSelectedImage != null) {
      if (newSelectedImage is UnstoredAbiliaFile) {
        BlocProvider.of<UserFileCubit>(context).fileAdded(
          newSelectedImage,
          image: true,
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
  final GestureTapCallback? onTap;
  final AbiliaFile selectedImage;

  final bool errorState;

  static final innerSize =
      SelectPictureWidget.imageSize - SelectPictureWidget.padding * 2;

  const SelectedImageWidget({
    Key? key,
    required this.selectedImage,
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
              )
            : Container(
                decoration: whiteNoBorderBoxDecoration,
                width: innerSize,
                height: innerSize,
                child: Icon(
                  AbiliaIcons.addPhoto,
                  size: layout.iconSize.normal,
                  color: AbiliaColors.black75,
                ),
              ),
      ),
    );
  }
}

class NameInput extends StatelessWidget {
  const NameInput({
    Key? key,
    required this.text,
    this.onEdit,
    this.errorState = false,
    this.maxLines = 1,
    this.inputFormatters = const <TextInputFormatter>[],
    this.inputHeading,
  }) : super(key: key);

  final String text;
  final Function(String)? onEdit;
  final bool errorState;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final String? inputHeading;

  @override
  Widget build(BuildContext context) {
    return AbiliaTextInput(
      initialValue: text,
      onChanged: onEdit,
      formKey: TestKey.editTitleTextFormField,
      errorState: errorState,
      icon: AbiliaIcons.edit,
      heading: Translator.of(context).translate.name,
      inputHeading: inputHeading ?? Translator.of(context).translate.name,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final Activity activity;

  const CategoryWidget(this.activity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    _onChange(v) => context
        .read<EditActivityCubit>()
        .replaceActivity(activity.copyWith(category: v));
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(translator.category),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: CategoryRadioField(
                    category: Category.left,
                    groupValue: activity.category,
                    onChanged: _onChange,
                  ),
                ),
                SizedBox(width: 8.s),
                Expanded(
                  child: CategoryRadioField(
                    category: Category.right,
                    groupValue: activity.category,
                    onChanged: _onChange,
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class CategoryRadioField extends StatelessWidget {
  final int category;

  final int groupValue;
  final ValueChanged<int?>? onChanged;

  final bool isRight;

  const CategoryRadioField({
    Key? key,
    required this.category,
    required this.groupValue,
    this.onChanged,
  })  : isRight = category == Category.right,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, state) {
        final fileId =
            isRight ? state.rightCategoryImage : state.leftCategoryImage;

        final label = isRight
            ? (state.rightCategoryName.isEmpty
                ? Translator.of(context).translate.right
                : state.rightCategoryName)
            : state.leftCategoryName.isEmpty
                ? Translator.of(context).translate.left
                : state.leftCategoryName;

        final nothing = fileId.isEmpty && !state.showCategoryColor;
        return RadioField<int>(
          key: isRight ? TestKey.rightCategoryRadio : TestKey.leftCategoryRadio,
          padding: nothing ? null : EdgeInsets.all(8.s),
          onChanged: onChanged,
          leading: nothing
              ? null
              : Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: CategoryImage.borderRadius,
                    border: border,
                  ),
                  child: CategoryImage(
                    fileId: fileId,
                    category: category,
                    showColors: state.showCategoryColor,
                  ),
                ),
          text: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
          groupValue: groupValue,
          value: category,
        );
      },
    );
  }
}

class AlarmWidget extends StatelessWidget {
  final Activity activity;

  const AlarmWidget(this.activity, {Key? key}) : super(key: key);

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
                    final authProviders = copiedAuthProviders(context);
                    final result = await Navigator.of(context)
                        .push<AlarmType>(MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: SelectAlarmTypePage(
                          alarm: alarm.typeSeagull,
                        ),
                      ),
                      settings:
                          const RouteSettings(name: 'SelectAlarmTypePage'),
                    ));
                    if (result != null) {
                      context.read<EditActivityCubit>().replaceActivity(
                            activity.copyWith(
                              alarm: activity.alarm.copyWith(type: result),
                            ),
                          );
                    }
                  }
                : null,
          ),
          SizedBox(height: 8.0.s),
          AlarmOnlyAtStartSwitch(
            alarm: alarm,
            onChanged: (v) => context.read<EditActivityCubit>().replaceActivity(
                  activity.copyWith(alarm: alarm.copyWith(onlyStart: v)),
                ),
          ),
        ],
      ),
    );
  }
}

class AlarmOnlyAtStartSwitch extends StatelessWidget {
  const AlarmOnlyAtStartSwitch({
    Key? key,
    required this.alarm,
    required this.onChanged,
  }) : super(key: key);

  final Alarm alarm;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchField(
        key: TestKey.alarmAtStartSwitch,
        leading: Icon(
          AbiliaIcons.handiAlarm,
          size: layout.iconSize.small,
        ),
        value: alarm.onlyStart,
        onChanged: alarm.shouldAlarm ? onChanged : null,
        child: Text(Translator.of(context).translate.alarmOnlyAtStartTime),
      );
}

class CheckableAndDeleteAfterWidget extends StatelessWidget {
  final Activity activity;

  const CheckableAndDeleteAfterWidget(this.activity, {Key? key})
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
            AbiliaIcons.handiCheck,
            size: layout.iconSize.small,
          ),
          value: activity.checkable,
          onChanged: (v) => context
              .read<EditActivityCubit>()
              .replaceActivity(activity.copyWith(checkable: v)),
          child: Text(translator.checkable),
        ),
        SizedBox(height: 8.0.s),
        SwitchField(
          key: TestKey.deleteAfterSwitch,
          leading: Icon(
            AbiliaIcons.deleteAllClear,
            size: layout.iconSize.small,
          ),
          value: activity.removeAfter,
          onChanged: (v) => context
              .read<EditActivityCubit>()
              .replaceActivity(activity.copyWith(removeAfter: v)),
          child: Text(translator.deleteAfter),
        ),
      ],
    );
  }
}

class AvailableForWidget extends StatelessWidget {
  final Activity activity;

  const AvailableForWidget(this.activity, {Key? key}) : super(key: key);

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
            secret ? AbiliaIcons.passwordProtection : AbiliaIcons.userGroup,
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
              context
                  .read<EditActivityCubit>()
                  .replaceActivity(activity.copyWith(secret: result));
            }
          },
        ),
      ],
    );
  }
}

class RecurrenceWidget extends StatelessWidget {
  final EditActivityState state;

  const RecurrenceWidget(this.state, {Key? key}) : super(key: key);

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
              settings: const RouteSettings(name: 'SelectRecurrencePage'),
            ));
            if (result != null) {
              if (state.storedRecurring &&
                  result == state.originalActivity.recurs.recurrance) {
                context.read<EditActivityCubit>().replaceActivity(
                      activity.copyWith(
                        recurs: state.originalActivity.recurs,
                      ),
                    );
              } else {
                final recurentType = _newType(
                  result,
                  state.timeInterval.startDate,
                );
                context.read<EditActivityCubit>().replaceActivity(
                      activity.copyWith(
                        recurs: recurentType,
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
  const EndDateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        final recurs = activity.recurs;
        final disabled = state.storedRecurring;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CollapsableWidget(
              collapsed: recurs.hasNoEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubHeading(translate.endDate),
                  DatePicker(
                    activity.recurs.end,
                    notBefore: state.timeInterval.startDate,
                    onChange: disabled
                        ? null
                        : (newDate) =>
                            context.read<EditActivityCubit>().replaceActivity(
                                  activity.copyWith(
                                    recurs: recurs.changeEnd(newDate),
                                  ),
                                ),
                  ),
                  SizedBox(height: 16.s),
                ],
              ),
            ),
            SwitchField(
              leading: Icon(
                AbiliaIcons.basicActivity,
                size: layout.iconSize.small,
              ),
              value: recurs.hasNoEnd,
              onChanged: disabled
                  ? null
                  : (v) => context.read<EditActivityCubit>().replaceActivity(
                        activity.copyWith(
                          recurs: recurs.changeEnd(
                            v ? Recurs.noEndDate : state.timeInterval.startDate,
                          ),
                        ),
                      ),
              child: Text(translate.noEndDate),
            ),
          ],
        );
      },
    );
  }
}

class EndDateWizWidget extends StatelessWidget {
  const EndDateWizWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        final recurs = activity.recurs;
        return SwitchField(
          leading: Icon(
            AbiliaIcons.basicActivity,
            size: layout.iconSize.small,
          ),
          value: recurs.hasNoEnd,
          onChanged: (v) => context.read<EditActivityCubit>().replaceActivity(
                activity.copyWith(
                  recurs: recurs.changeEnd(
                    v ? Recurs.noEndDate : state.timeInterval.startDate,
                  ),
                ),
              ),
          child: Text(translate.noEndDate),
        );
      },
    );
  }
}

class WeekDays extends StatelessWidget {
  const WeekDays({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return DefaultTextStyle(
      style: (Theme.of(context).textTheme.bodyText1 ?? bodyText1)
          .copyWith(height: 1.5.s),
      child: BlocBuilder<RecurringWeekCubit, RecurringWeekState>(
        buildWhen: (previous, current) => previous.weekdays != current.weekdays,
        builder: (context, state) => Wrap(
          spacing: 14.s,
          runSpacing: 8.s,
          children: [
            ...RecurringWeekState.allWeekdays.map(
              (d) => SelectableField(
                text: Text(translate.shortWeekday(d)),
                selected: state.weekdays.contains(d),
                onTap: () =>
                    context.read<RecurringWeekCubit>().addOrRemoveWeekday(d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthDays extends StatelessWidget {
  const MonthDays({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final selectedMonthDays = state.activity.recurs.monthDays;
        return Wrap(
          spacing: 14.0.s,
          runSpacing: 8.0.s,
          children: List.generate(
            31,
            (i) {
              final d = i + 1;
              return SelectableField(
                text: Text(
                  '$d',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(height: 1.5),
                ),
                selected: selectedMonthDays.contains(d),
                onTap: () {
                  if (!selectedMonthDays.add(d)) {
                    selectedMonthDays.remove(d);
                  }
                  context.read<EditActivityCubit>().replaceActivity(
                        state.activity.copyWith(
                          recurs: Recurs.monthlyOnDays(
                            selectedMonthDays,
                            ends: state.activity.recurs.end,
                          ),
                        ),
                      );
                },
              );
            },
          ),
        );
      },
    );
  }
}
