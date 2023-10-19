import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class CategoryWiz extends StatelessWidget {
  const CategoryWiz({super.key});

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.categories,
      title: Lt.of(context).selectCategory,
      body: Padding(
        padding: layout.templates.m1,
        child: const _CategoryWidget(),
      ),
    );
  }
}

class _CategoryWidget extends StatelessWidget {
  const _CategoryWidget();

  @override
  Widget build(BuildContext context) {
    final category = context
        .select((EditActivityCubit cubit) => cubit.state.activity.category);
    final editActivityCubit = context.read<EditActivityCubit>();
    final activity = editActivityCubit.state.activity;
    return Column(
      children: <Widget>[
        CategoryRadioField(
          category: Category.left,
          groupValue: category,
          onChanged: (value) => editActivityCubit
              .replaceActivity(activity.copyWith(category: value)),
        ),
        SizedBox(height: layout.formPadding.verticalItemDistance),
        CategoryRadioField(
          category: Category.right,
          groupValue: category,
          onChanged: (value) => editActivityCubit
              .replaceActivity(activity.copyWith(category: value)),
        ),
      ],
    );
  }
}
