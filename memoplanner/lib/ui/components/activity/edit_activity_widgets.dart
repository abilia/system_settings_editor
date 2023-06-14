import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityNameAndPictureWidget extends StatelessWidget {
  const ActivityNameAndPictureWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editActivitySettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.addActivity.editActivity);
    final selectedImage =
        context.select((EditActivityCubit c) => c.state.selectedImage);
    final activity = context.select((EditActivityCubit c) => c.state.activity);
    final saveErrors = context.select((WizardCubit c) => c.state.saveErrors);

    return NameAndPictureWidget(
      selectedImage: selectedImage,
      errorState: saveErrors.contains(SaveError.noTitleOrImage),
      text: activity.title,
      inputFormatters: [LengthLimitingTextInputFormatter(50)],
      onImageSelected: editActivitySettings.image
          ? context.read<EditActivityCubit>().imageSelected
          : null,
      onTextEdit: editActivitySettings.title
          ? (text) {
              if (activity.title != text) {
                context
                    .read<EditActivityCubit>()
                    .replaceActivity(activity.copyWith(title: text));
              }
            }
          : null,
      inputHeadingForNameField: _heading(context),
    );
  }

  String _heading(BuildContext context) {
    final translate = Lt.of(context);
    final isTemplate =
        context.read<WizardCubit>() is TemplateActivityWizardCubit;
    if (isTemplate) return translate.enterNameForActivity;
    return translate.enterNameForActivity;
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
    required this.selectedImage,
    required this.text,
    this.onImageSelected,
    this.onTextEdit,
    this.errorState = false,
    this.maxLines = 1,
    this.inputFormatters = const <TextInputFormatter>[],
    this.inputHeadingForNameField,
    Key? key,
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
            onImageSelected: onImageSelected != null
                ? (imageAndName) => onImageSelected?.call(imageAndName.image)
                : null,
            errorState: errorState,
          ),
          SizedBox(width: layout.formPadding.largeVerticalItemDistance),
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
  final AbiliaFile selectedImage;
  final void Function(ImageAndName)? onImageSelected;
  final bool errorState, isLarge;
  final String? label;

  const SelectPictureWidget({
    required this.selectedImage,
    required this.onImageSelected,
    this.errorState = false,
    this.isLarge = false,
    this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heading = Lt.of(context).picture;
    return Tts.fromSemantics(
      SemanticsProperties(button: true, label: heading),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SubHeading(heading),
          SelectedImageWidget(
            errorState: errorState,
            isLarge: isLarge,
            onTap: onImageSelected != null
                ? () async => imageClick(context)
                : null,
            selectedImage: selectedImage,
          ),
        ],
      ),
    );
  }

  Future<void> imageClick(BuildContext context) async {
    final authProviders = copiedAuthProviders(context);
    final userFileBloc = context.read<UserFileBloc>();
    final sortableBloc = context.read<SortableBloc>();
    final now = context.read<ClockBloc>().state;
    final imageAndName = await Navigator.of(context).push<ImageAndName>(
      PersistentMaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
          child: SelectPicturePage(
            selectedImage: selectedImage,
            label: label,
          ),
        ),
        settings: (SelectPicturePage).routeSetting(),
      ),
    );
    final newSelectedImage = imageAndName?.image;

    if (newSelectedImage != null) {
      String name = imageAndName?.name ?? '';
      if (newSelectedImage is UnstoredAbiliaFile) {
        name = DateFormat.yMd(Platform.localeName).format(now);
        userFileBloc.add(
          FileAdded(
            newSelectedImage,
            isImage: true,
          ),
        );
        sortableBloc.add(
          ImageArchiveImageAdded(
            newSelectedImage.id,
            name,
          ),
        );
      }
      onImageSelected?.call(ImageAndName(name, newSelectedImage));
    }
  }
}

class SelectedImageWidget extends StatelessWidget {
  final GestureTapCallback? onTap;
  final AbiliaFile selectedImage;

  final bool errorState, isLarge;

  const SelectedImageWidget({
    required this.selectedImage,
    this.errorState = false,
    this.isLarge = false,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final imageSize = isLarge
        ? layout.selectPicture.imageSizeLarge
        : layout.selectPicture.imageSize;
    final innerSize = imageSize -
        (isLarge
                ? layout.selectPicture.paddingLarge
                : layout.selectPicture.padding) *
            2;

    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: LinedBorder(
        key: TestKey.addPicture,
        errorState: errorState,
        onTap: onTap,
        child: Center(
          child: selectedImage.isNotEmpty
              ? Opacity(
                  opacity: disabled ? 0.4 : 1,
                  child: FadeInCalendarImage(
                    height: innerSize,
                    width: innerSize,
                    imageFile: selectedImage,
                  ),
                )
              : Container(
                  decoration: disabled
                      ? disabledBoxDecoration
                      : whiteNoBorderBoxDecoration,
                  width: innerSize,
                  height: innerSize,
                  child: Icon(
                    AbiliaIcons.addPhoto,
                    size: layout.icon.normal,
                    color: AbiliaColors.black75,
                  ),
                ),
        ),
      ),
    );
  }
}

class NameInput extends StatelessWidget {
  const NameInput({
    required this.text,
    required this.onEdit,
    this.errorState = false,
    this.maxLines = 1,
    this.inputFormatters = const <TextInputFormatter>[],
    this.inputHeading,
    Key? key,
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
      heading: Lt.of(context).name,
      inputHeading: inputHeading ?? Lt.of(context).name,
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
    final translator = Lt.of(context);
    void onChange(v) => context
        .read<EditActivityCubit>()
        .replaceActivity(activity.copyWith(category: v));
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
                onChanged: onChange,
              ),
            ),
            SizedBox(width: layout.formPadding.verticalItemDistance),
            Expanded(
              child: CategoryRadioField(
                category: Category.right,
                groupValue: activity.category,
                onChanged: onChange,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class CategoryRadioField extends StatelessWidget {
  final int category;

  final int groupValue;
  final ValueChanged<int?>? onChanged;

  final bool isRight;

  const CategoryRadioField({
    required this.category,
    required this.groupValue,
    this.onChanged,
    Key? key,
  })  : isRight = category == Category.right,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoriesSettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.categories);
    final imageAndName =
        isRight ? categoriesSettings.right : categoriesSettings.left;
    final fileId = imageAndName.image.id;

    final label = imageAndName.hasName
        ? imageAndName.name
        : isRight
            ? Lt.of(context).right
            : Lt.of(context).left;

    final nothing = fileId.isEmpty && !categoriesSettings.showColors;
    return RadioField<int>(
      key: isRight ? TestKey.rightCategoryRadio : TestKey.leftCategoryRadio,
      padding: nothing ? null : layout.category.activityRadioPadding,
      onChanged: onChanged,
      leading: nothing
          ? null
          : Container(
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: border,
              ),
              child: CategoryImage(
                fileId: fileId,
                showBorder: fileId.isEmpty,
                color:
                    fileId.isEmpty ? categoryColor(category: category) : null,
                diameter: layout.category.radioImageDiameter,
              ),
            ),
      text: Text(
        label,
        overflow: TextOverflow.ellipsis,
      ),
      groupValue: groupValue,
      value: category,
    );
  }
}

class AlarmWidget extends StatelessWidget {
  const AlarmWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Lt.of(context);
    final editActivityCubit = context.watch<EditActivityCubit>();
    final activity = editActivityCubit.state.activity;
    final alarm = activity.alarm;
    final generalSettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.addActivity.general);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.alarm),
        PickField(
          key: TestKey.selectAlarm,
          leading: Icon(alarm.iconData()),
          text: Text(alarm.text(translator)),
          onTap: generalSettings.abilityToSelectAlarm
              ? () async {
                  final authProviders = [
                    BlocProvider.value(value: editActivityCubit),
                    ...copiedAuthProviders(context)
                  ];
                  final result = await Navigator.of(context).push<bool>(
                    PersistentMaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: SelectAlarmTypePage(
                          onOk: () => Navigator.of(context).maybePop(true),
                        ),
                      ),
                      settings: (SelectAlarmTypePage).routeSetting(),
                    ),
                  );
                  if (result != true) {
                    editActivityCubit.replaceActivity(activity);
                  }
                }
              : null,
        ),
        if (generalSettings.showAlarmOnlyAtStart) ...[
          SizedBox(height: layout.formPadding.verticalItemDistance),
          const AlarmOnlyAtStartSwitch(),
        ],
      ],
    );
  }
}

class AlarmOnlyAtStartSwitch extends StatelessWidget {
  const AlarmOnlyAtStartSwitch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alarm =
        context.select((EditActivityCubit cubit) => cubit.state.activity.alarm);
    return SwitchField(
      key: TestKey.alarmAtStartSwitch,
      leading: Icon(
        AbiliaIcons.handiAlarm,
        size: layout.icon.small,
      ),
      value: alarm.onlyStart,
      onChanged: alarm.shouldAlarm
          ? (alarmOnlyOnStart) {
              final cubit = context.read<EditActivityCubit>();
              final activity = cubit.state.activity;
              cubit.replaceActivity(activity.copyWith(
                  alarm: alarm.copyWith(onlyStart: alarmOnlyOnStart)));
            }
          : null,
      child: Text(Lt.of(context).alarmOnlyAtStartTime),
    );
  }
}

class CheckableAndDeleteAfterWidget extends StatelessWidget {
  final Activity activity;

  const CheckableAndDeleteAfterWidget(this.activity, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Lt.of(context);
    final editActivitySettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.addActivity.editActivity);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (editActivitySettings.checkable)
          Padding(
            padding: EdgeInsets.only(
              bottom: layout.formPadding.verticalItemDistance,
            ),
            child: SwitchField(
              key: TestKey.checkableSwitch,
              leading: Icon(
                AbiliaIcons.handiCheck,
                size: layout.icon.small,
              ),
              value: activity.checkable,
              onChanged: (v) => context
                  .read<EditActivityCubit>()
                  .replaceActivity(activity.copyWith(checkable: v)),
              child: Text(translator.checkable),
            ),
          ),
        if (editActivitySettings.removeAfter)
          SwitchField(
            key: TestKey.deleteAfterSwitch,
            leading: Icon(
              AbiliaIcons.deleteAllClear,
              size: layout.icon.small,
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
    final translator = Lt.of(context);
    final availableFor = activity.availableFor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.availableFor),
        PickField(
          leading: Icon(availableFor.icon),
          text: Text(
            availableFor.text(translator),
          ),
          onTap: () async => onTap(context),
        ),
      ],
    );
  }

  Future<void> onTap(BuildContext context) async {
    final authenticatedState = context.read<AuthenticationBloc>().state;
    if (authenticatedState is Authenticated) {
      final editActivityCubit = context.read<EditActivityCubit>();
      final availableForState = await navigateToAvailableForPage(
        context,
        authenticatedState.userId,
      );
      if (availableForState != null) {
        editActivityCubit.replaceActivity(
          activity.copyWith(
            secret: availableForState.availableFor !=
                AvailableForType.allSupportPersons,
            secretExemptions: availableForState.selectedSupportPersons,
          ),
        );
      }
    }
  }

  Future<AvailableForState?> navigateToAvailableForPage(
    BuildContext context,
    int userId,
  ) {
    final supportPersonsCubit = context.read<SupportPersonsCubit>();
    return Navigator.of(context).push<AvailableForState>(
      PersistentMaterialPageRoute(
        settings: (AvailableForPage).routeSetting(),
        builder: (context) => BlocProvider<AvailableForCubit>(
          create: (context) => AvailableForCubit(
            supportPersonsCubit: supportPersonsCubit..loadSupportPersons(),
            availableFor: activity.availableFor,
            selectedSupportPersons: activity.secretExemptions,
          ),
          child: const AvailableForPage(),
        ),
      ),
    );
  }
}

class EndDateWidget extends StatelessWidget {
  const EndDateWidget({required this.errorState, Key? key}) : super(key: key);

  final bool errorState;

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final disabled = state.storedRecurring;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CollapsableWidget(
              collapsed: state.recursWithNoEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubHeading(translate.endDate),
                  DatePicker(
                    state.timeInterval.endDate ?? state.timeInterval.startDate,
                    notBefore: state.timeInterval.startDate,
                    onChange: disabled
                        ? null
                        : (newDate) => context
                            .read<EditActivityCubit>()
                            .changeRecurrentEndDate(newDate),
                    emptyText: !state.hasEndDate || state.recursWithNoEnd,
                    errorState: errorState,
                  ),
                  SizedBox(height: layout.formPadding.groupBottomDistance),
                ],
              ),
            ),
            SwitchField(
              key: TestKey.noEndDateSwitch,
              leading: Icon(
                AbiliaIcons.basicActivity,
                size: layout.icon.small,
              ),
              value: state.recursWithNoEnd,
              onChanged: disabled
                  ? null
                  : (v) => context
                      .read<EditActivityCubit>()
                      .changeRecurrentEndDate(v ? noEndDate : null),
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
    final translate = Lt.of(context);
    final recursWithNoEnd = context
        .select((EditActivityCubit cubit) => cubit.state.recursWithNoEnd);
    return SwitchField(
      key: TestKey.noEndDateSwitch,
      leading: Icon(
        AbiliaIcons.basicActivity,
        size: layout.icon.small,
      ),
      value: recursWithNoEnd,
      onChanged: (v) => context
          .read<EditActivityCubit>()
          .changeRecurrentEndDate(v ? noEndDate : null),
      child: Text(translate.noEndDate),
    );
  }
}

class Weekdays extends StatelessWidget {
  const Weekdays({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final dateFormat = DateFormat('', '${Localizations.localeOf(context)}');
    final weekdaysTts = dateFormat.dateSymbols.STANDALONEWEEKDAYS;
    final weekdays =
        context.select((RecurringWeekCubit bloc) => bloc.state.weekdays);
    return DefaultTextStyle(
      style: (Theme.of(context).textTheme.bodyLarge ?? bodyLarge)
          .copyWith(height: 1.5),
      child: Padding(
        padding: EdgeInsets.only(top: layout.selectableField.position.abs()),
        child: Wrap(
          spacing: layout.formPadding.horizontalItemDistance,
          runSpacing: layout.formPadding.verticalItemDistance,
          children: [
            ...RecurringWeekState.allWeekdays.map(
              (day) => BlocSelector<MemoplannerSettingsBloc,
                  MemoplannerSettings, DayTheme>(
                selector: (state) => weekdayTheme(
                  dayColor: state.calendar.dayColor,
                  languageCode: Localizations.localeOf(context).languageCode,
                  weekday: day,
                ),
                builder: (context, dayTheme) => SelectableField(
                  text: Text(
                    translate.shortWeekday(day),
                    style: TextStyle(color: dayTheme.monthSurfaceColor),
                  ),
                  color: dayTheme.dayColor,
                  selected: weekdays.contains(day),
                  onTap: () => context
                      .read<RecurringWeekCubit>()
                      .addOrRemoveWeekday(day),
                  ttsData: weekdaysTts[day % DateTime.daysPerWeek],
                ),
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
        return Padding(
          padding: EdgeInsets.only(top: layout.selectableField.position.abs()),
          child: Wrap(
            spacing: layout.formPadding.horizontalItemDistance,
            runSpacing: layout.formPadding.horizontalItemDistance,
            children: List.generate(
              31,
              (i) {
                final d = i + 1;
                return SelectableField(
                  text: Text(
                    '$d',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                  ),
                  selected: selectedMonthDays.contains(d),
                  onTap: () {
                    if (!selectedMonthDays.add(d)) {
                      selectedMonthDays.remove(d);
                    }
                    context
                        .read<EditActivityCubit>()
                        .changeSelectedMonthDays(selectedMonthDays);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
