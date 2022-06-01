import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/support_persons_cubit.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/ui/all.dart';

class AvailableForPage extends StatelessWidget {
  const AvailableForPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<AvailableForCubit, AvailableForState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.unlock,
          title: translate.availableFor,
        ),
        body: Padding(
          padding: layout.templates.m1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RadioField<AvailableForType>(
                groupValue: state.availableFor,
                onChanged: (value) => _onSelected(context, value),
                value: AvailableForType.onlyMe,
                leading: const Icon(AbiliaIcons.lock),
                text: Text(translate.onlyMe),
              ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              RadioField<AvailableForType>(
                groupValue: state.availableFor,
                onChanged: (value) => _onSelected(context, value),
                value: AvailableForType.allSupportPersons,
                leading: const Icon(AbiliaIcons.unlock),
                text: Text(translate.allSupportPersons),
              ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              RadioField<AvailableForType?>(
                groupValue: state.availableFor,
                onChanged: (value) => _onSelected(context, value),
                value: AvailableForType.selectedSupportPersons,
                leading: const Icon(AbiliaIcons.unlock),
                text: Text(translate.selectedSupportPersons),
              ),
              if (state.availableFor == AvailableForType.selectedSupportPersons)
                const Expanded(
                  child: SupportPersonsWidget(),
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: () => Navigator.of(context).maybePop(state),
          ),
        ),
      ),
    );
  }

  void _onSelected(BuildContext context, AvailableForType? value) {
    if (value != null) {
      context.read<AvailableForCubit>().setAvailableFor(value);
    }
  }
}

class SupportPersonsWidget extends StatelessWidget {
  const SupportPersonsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final iconSize = layout.icon.small;
    return ScrollArrows.vertical(
      controller: scrollController,
      child: BlocBuilder<AvailableForCubit, AvailableForState>(
        builder: (context, state) {
          return ListView(
            controller: scrollController,
            children: <Widget>[
              const Divider(),
              Tts(
                child: Text(Translator.of(context).translate.supportPersons),
              ),
              ...state.allSupportPersons
                  .map((person) => SwitchField(
                        key: TestKey.fullDaySwitch,
                        leading: person.image.isNotEmpty
                            ? FadeInAbiliaImage(
                                imageFileId: person.image,
                                width: iconSize,
                                height: iconSize,
                              )
                            : Icon(
                                AbiliaIcons.stop,
                                size: iconSize,
                              ),
                        value: state.selectedSupportPersons.contains(person.id),
                        onChanged: (selected) => {
                          context
                              .read<AvailableForCubit>()
                              .selectSupportPerson(person, selected)
                        },
                        child: Text(person.name),
                      ))
                  .toList(),
            ],
          );
        },
      ),
    );
  }
}
