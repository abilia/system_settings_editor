import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/activity_wizard/activity_wizard_cubit.dart';
import 'package:seagull/bloc/activities/activity_wizard/type_wiz_cubit.dart';
import 'package:seagull/bloc/activities/activity_wizard/type_wiz_state.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_bloc.dart';
import 'package:seagull/bloc/generic/memoplannersetting/memoplanner_setting_bloc.dart';
import 'package:seagull/models/category.dart';
import 'package:seagull/ui/all.dart';

class TypeWiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var activity = context.read<EditActivityBloc>().state.activity;
    return BlocProvider(
      create: (_) => TypeWizCubit(
          initialType: activity.fullDay
              ? CategoryType.fullDay
              : activity.category == Category.left
                  ? CategoryType.left
                  : CategoryType.right),
      child: Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.plus,
          title: Translator.of(context).translate.selectType,
        ),
        body: Padding(
          padding: ordinaryPadding,
          child: BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
            builder: (context, wizState) => _TypeWidget(),
          ),
        ),
        bottomNavigationBar: BlocBuilder<TypeWizCubit, TypeWizState>(
          builder: (context, typeState) {
            return WizardBottomNavigation(
              beforeOnNext: () {
                context.read<EditActivityBloc>().add(ChangeCategory(
                    fullDay: typeState.type == CategoryType.fullDay,
                    category: typeState.type == CategoryType.left
                        ? Category.left
                        : Category.right));
              },
            );
          },
        ),
      ),
    );
  }
}

class _TypeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var onChanged = (v) {
      context.read<TypeWizCubit>().updateType(v);
    };
    return BlocBuilder<TypeWizCubit, TypeWizState>(
        buildWhen: (previous, current) => previous.type != current.type,
        builder: (typeContext, typeState) {
          return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TypeRadioField(
                    category: CategoryType.fullDay,
                    radioKey: TestKey.fullDayCategoryRadio,
                    label: Translator.of(context).translate.fullDay,
                    image: Icon(
                      AbiliaIcons.restore,
                      size: smallIconSize,
                    ),
                    groupValue: typeState.type,
                    onChanged: onChanged,
                  ),
                  SizedBox(height: 8.s),
                  TypeRadioField(
                    category: CategoryType.left,
                    radioKey: TestKey.leftCategoryRadio,
                    label: state.leftCategoryName.isEmpty
                        ? Translator.of(context).translate.left
                        : state.leftCategoryName,
                    image: CategoryImage(
                      fileId: state.leftCategoryImage,
                      category: CategoryType.left.index,
                      showColors: state.showCategoryColor,
                    ),
                    groupValue: typeState.type,
                    onChanged: onChanged,
                  ),
                  SizedBox(height: 8.s),
                  TypeRadioField(
                    category: CategoryType.right,
                    radioKey: TestKey.rightCategoryRadio,
                    label: state.rightCategoryName.isEmpty
                        ? Translator.of(context).translate.right
                        : state.rightCategoryName,
                    image: CategoryImage(
                      fileId: state.rightCategoryImage,
                      category: CategoryType.right.index,
                      showColors: state.showCategoryColor,
                    ),
                    groupValue: typeState.type,
                    onChanged: onChanged,
                  ),
                ],
              );
            },
          );
        });
  }
}

class TypeRadioField extends StatelessWidget {
  final String label;
  final CategoryType category;
  final Key radioKey;
  final Widget? image;
  final CategoryType groupValue;
  final ValueChanged<CategoryType?>? onChanged;

  const TypeRadioField({
    Key? key,
    required this.label,
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
        return RadioField<CategoryType>(
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
