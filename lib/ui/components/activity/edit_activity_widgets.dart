import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/form/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class NameAndPictureWidget extends StatelessWidget {
  final Activity activity;
  final File newImage;

  const NameAndPictureWidget(
    this.activity, {
    Key key,
    this.newImage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    final imageClick = () async {
      final selectedImage = await showViewDialog<SelectedImage>(
        context: context,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<ImageArchiveBloc>(
              create: (_) => ImageArchiveBloc(
                sortableBloc: BlocProvider.of<SortableBloc>(context),
              ),
            ),
            BlocProvider<UserFileBloc>.value(
              value: BlocProvider.of<UserFileBloc>(context),
            ),
          ],
          child: SelectPictureDialog(previousImage: activity.fileId),
        ),
      );
      if (selectedImage != null) {
        BlocProvider.of<EditActivityBloc>(context).add(ImageSelected(
          selectedImage.id,
          selectedImage.path,
          selectedImage.newImage,
        ));
        if (selectedImage.newImage != null) {
          BlocProvider.of<UserFileBloc>(context).add(ImageAdded(
              selectedImage.id, selectedImage.path, selectedImage.newImage));
          BlocProvider.of<SortableBloc>(context).add(ImageArchiveImageAdded(
            selectedImage.id,
            selectedImage.newImage.path,
          ));
        }
      }
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(translator.picture),
            if (activity.hasImage)
              InkWell(
                onTap: imageClick,
                child: FadeInCalendarImage(
                  height: 84,
                  width: 84,
                  imageFileId: activity.fileId,
                  imageFilePath: activity.icon,
                  activityId: activity.id,
                  imageFile: newImage,
                ),
              )
            else
              LinedBorder(
                key: TestKey.addPicture,
                padding: const EdgeInsets.all(26),
                child: const Icon(
                  AbiliaIcons.add_photo,
                  size: 32,
                  color: AbiliaColors.black75,
                ),
                onTap: imageClick,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SubHeading(translator.name),
              TextFormField(
                initialValue: activity.title,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                onChanged: (text) => BlocProvider.of<EditActivityBloc>(context)
                    .add(ReplaceActivity(activity.copyWith(title: text))),
                key: TestKey.editTitleTextFormField,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final Activity activity;

  const CategoryWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.category),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildCategoryRadioField(context, Category.left),
            const SizedBox(width: 8),
            buildCategoryRadioField(context, Category.right),
          ],
        )
      ],
    );
  }

  Expanded buildCategoryRadioField(BuildContext context, int category) {
    final left = category == Category.left;
    final key = left ? TestKey.leftCategoryRadio : TestKey.rightCategoryRadio;
    final icon =
        left ? AbiliaIcons.move_item_left : AbiliaIcons.move_item_right;
    final text = left
        ? Translator.of(context).translate.left
        : Translator.of(context).translate.right;
    return Expanded(
      child: RadioField(
        key: key,
        onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
            .add(ReplaceActivity(activity.copyWith(category: v))),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 6),
            Icon(icon),
            const SizedBox(width: 12),
            Text(text)
          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.alarm),
        PickField(
          key: TestKey.selectAlarm,
          leading: Icon(alarm.iconData()),
          label: Text(alarm.text(translator)),
          onTap: () async {
            final result = await showViewDialog<Alarm>(
              context: context,
              builder: (context) => SelectAlarmTypeDialog(
                alarm: alarm.type,
              ),
            );
            if (result != null) {
              BlocProvider.of<EditActivityBloc>(context).add(ReplaceActivity(
                  activity.copyWith(
                      alarm: activity.alarm.copyWith(type: result))));
            }
          },
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
    );
  }
}

class AlarmOnlyAtStartSwitch extends StatelessWidget {
  const AlarmOnlyAtStartSwitch({
    Key key,
    @required this.alarm,
    @required this.onChanged,
  }) : super(key: key);

  final AlarmType alarm;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchField(
        key: TestKey.alarmAtStartSwitch,
        leading: Icon(AbiliaIcons.handi_alarm),
        label: Text(Translator.of(context).translate.alarmOnlyAtStartTime),
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
          leading: Icon(AbiliaIcons.handi_check),
          label: Text(translator.checkable),
          value: activity.checkable,
          onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
              .add(ReplaceActivity(activity.copyWith(checkable: v))),
        ),
        const SizedBox(height: 8.0),
        SwitchField(
          key: TestKey.deleteAfterSwitch,
          leading: Icon(AbiliaIcons.delete_all_clear),
          label: Text(translator.deleteAfter),
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
          leading: Icon(secret
              ? AbiliaIcons.password_protection
              : AbiliaIcons.user_group),
          label:
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
