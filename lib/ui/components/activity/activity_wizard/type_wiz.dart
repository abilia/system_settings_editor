import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class TypeWiz extends StatelessWidget {
  const TypeWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.plus,
      title: Translator.of(context).translate.selectType,
      body: Padding(
        padding: ordinaryPadding,
        child: const _TypeWidget(),
      ),
    );
  }
}

class _TypeWidget extends StatelessWidget {
  const _TypeWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, setting) {
        return BlocBuilder<EditActivityBloc, EditActivityState>(
          buildWhen: (previous, current) =>
              previous.activity.fullDay != current.activity.fullDay ||
              previous.activity.category != current.activity.category,
          builder: (typeContext, state) {
            const _fullDayValue = -1;
            final activity = state.activity;
            _onChange(int? value) => context.read<EditActivityBloc>().add(
                  ReplaceActivity(
                    activity.copyWith(
                      fullDay: value == _fullDayValue,
                      category: value?.isNegative == true ? null : value,
                    ),
                  ),
                );
            final groupValue =
                activity.fullDay ? _fullDayValue : activity.category;

            return Column(
              children: <Widget>[
                RadioField<int>(
                    text: Text(
                      Translator.of(context).translate.fullDay,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Icon(
                      AbiliaIcons.restore,
                      size: Lay.out.icon.small,
                    ),
                    value: _fullDayValue,
                    groupValue: groupValue,
                    onChanged: _onChange),
                SizedBox(height: 8.s),
                CategoryRadioField(
                  category: Category.left,
                  groupValue: groupValue,
                  onChanged: _onChange,
                ),
                SizedBox(height: 8.s),
                CategoryRadioField(
                  category: Category.right,
                  groupValue: groupValue,
                  onChanged: _onChange,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
