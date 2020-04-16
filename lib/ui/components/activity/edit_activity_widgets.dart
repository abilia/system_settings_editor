import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
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
        BlocProvider.of<EditActivityBloc>(context)
            .add(ImageSelected(selectedImage.id, selectedImage.newImage));
        if (selectedImage.newImage != null) {
          BlocProvider.of<UserFileBloc>(context)
              .add(ImageAdded(selectedImage.id, selectedImage.newImage));
          BlocProvider.of<SortableBloc>(context).add(ImageArchiveImageAdded(
            selectedImage.id,
            selectedImage.newImage.path,
          ));
        }
      }
    };
    return SizedBox(
      height: 84,
      child: Row(
        children: <Widget>[
          activity.hasImage
              ? InkWell(
                  onTap: imageClick,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FadeInCalendarImage(
                      height: 84,
                      width: 84,
                      imageFileId: activity.fileId,
                      imageFilePath: activity.icon,
                      activityId: activity.id,
                      imageFile: newImage,
                    ),
                  ),
                )
              : LinedBorder(
                  key: TestKey.addPicture,
                  padding: const EdgeInsets.all(26),
                  child: Icon(
                    AbiliaIcons.add_photo,
                    size: 32,
                    color: AbiliaColors.black[75],
                  ),
                  onTap: imageClick,
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
                  onChanged: (text) =>
                      BlocProvider.of<EditActivityBloc>(context)
                          .add(ChangeActivity(activity.copyWith(title: text))),
                  key: TestKey.editTitleTextFormField,
                ),
              ],
            ),
          ),
        ],
      ),
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
            Expanded(
              child: RadioField(
                key: TestKey.leftCategoryRadio,
                onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
                    .add(ChangeActivity(activity.copyWith(category: v))),
                child: Row(
                  children: <Widget>[
                    circle(),
                    const SizedBox(width: 12),
                    Text(translator.left)
                  ],
                ),
                groupValue: activity.category,
                value: Category.left,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RadioField(
                key: TestKey.rightCategoryRadio,
                onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
                    .add(ChangeActivity(activity.copyWith(category: v))),
                child: Row(
                  children: <Widget>[
                    circle(),
                    const SizedBox(width: 12),
                    Text(translator.right)
                  ],
                ),
                groupValue: activity.category,
                value: Category.right,
              ),
            ),
          ],
        )
      ],
    );
  }

  circle() => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AbiliaColors.transparentBlack[15],
          ),
          color: AbiliaColors.white,
        ),
      );
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
              BlocProvider.of<EditActivityBloc>(context).add(ChangeActivity(
                  activity.copyWith(
                      alarm: activity.alarm.copyWith(type: result))));
            }
          },
        ),
        const SizedBox(height: 8.0),
        AlarmOnlyAtStartSwitch(
          alarm: alarm,
          onChanged: (v) => BlocProvider.of<EditActivityBloc>(context).add(
            ChangeActivity(
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
              .add(ChangeActivity(activity.copyWith(checkable: v))),
        ),
        const SizedBox(height: 8.0),
        SwitchField(
          key: TestKey.deleteAfterSwitch,
          leading: Icon(AbiliaIcons.delete_all_clear),
          label: Text(translator.deleteAfter),
          value: activity.removeAfter,
          onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
              .add(ChangeActivity(activity.copyWith(removeAfter: v))),
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
    final bool secret = activity.secret;
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
                  .add(ChangeActivity(activity.copyWith(secret: result)));
            }
          },
        ),
      ],
    );
  }
}
