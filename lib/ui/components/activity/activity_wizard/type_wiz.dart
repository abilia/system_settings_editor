import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/activity_wizard/activity_wizard_cubit.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_bloc.dart';
import 'package:seagull/bloc/generic/memoplannersetting/memoplanner_setting_bloc.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/models/category.dart';
import 'package:seagull/ui/all.dart';

enum _Type {
  right,
  left,
  fullDay,
}

class TypeWiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.plus,
          title: Translator.of(context).translate.selectType,
        ),
        body: Padding(
          padding: ordinaryPadding,
          child: BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
            builder: (context, wizState) => _TypeWidget(
              state.activity,
            ),
          ),
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
  }
}

class _TypeWidget extends StatefulWidget {
  final Activity _activity;

  const _TypeWidget(this._activity, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TypeState(_activity);
  }
}

class _TypeState extends State<_TypeWidget> {
  final Activity activity;
  late _Type groupType;

  _TypeState(this.activity) {
    groupType = activity.fullDay
        ? _Type.fullDay
        : activity.category == Category.left
            ? _Type.left
            : _Type.right;
  }

  @override
  Widget build(BuildContext context) {
    var onChanged = (v) {
      BlocProvider.of<EditActivityBloc>(context).add(ReplaceActivity(
          activity.copyWith(
              category: v == _Type.left ? Category.left : Category.right,
              fullDay: v == _Type.fullDay)));
      groupType = v;
    };
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TypeRadioField(
              category: _Type.fullDay,
              radioKey: TestKey.fullDayCategoryRadio,
              activity: activity,
              label: Translator.of(context).translate.fullDay,
              image: Icon(
                AbiliaIcons.restore,
                size: smallIconSize,
              ),
              groupValue: groupType,
              onChanged: onChanged,
            ),
            SizedBox(height: 8.s),
            TypeRadioField(
              category: _Type.left,
              radioKey: TestKey.leftCategoryRadio,
              activity: activity,
              label: state.leftCategoryName.isEmpty
                  ? Translator.of(context).translate.left
                  : state.leftCategoryName,
              image: CategoryImage(
                fileId: state.leftCategoryImage,
                category: _Type.left.index,
                showColors: state.showCategoryColor,
              ),
              groupValue: groupType,
              onChanged: onChanged,
            ),
            SizedBox(height: 8.s),
            TypeRadioField(
              category: _Type.right,
              radioKey: TestKey.rightCategoryRadio,
              activity: activity,
              label: state.rightCategoryName.isEmpty
                  ? Translator.of(context).translate.right
                  : state.rightCategoryName,
              image: CategoryImage(
                fileId: state.rightCategoryImage,
                category: _Type.right.index,
                showColors: state.showCategoryColor,
              ),
              groupValue: groupType,
              onChanged: onChanged,
            ),
          ],
        );
      },
    );
  }
}

class TypeRadioField extends StatelessWidget {
  final String label;
  final Activity activity;
  final _Type category;
  final Key radioKey;
  final Widget? image;
  final _Type groupValue;
  final ValueChanged<_Type?>? onChanged;

  const TypeRadioField({
    Key? key,
    required this.label,
    required this.activity,
    required this.category,
    required this.radioKey,
    required this.image,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.showCategoryColor != current.showCategoryColor,
      builder: (context, settingState) {
        final nothing = image == null && !settingState.showCategoryColor;
        return RadioField<_Type>(
          key: radioKey,
          padding: nothing ? null : EdgeInsets.all(8.s),
          onChanged: onChanged,
          leading: nothing
              ? null
              : Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: CategoryImage.borderRadius,
                    border: border,
                  ),
                  child: image,
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
