import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/db/baseurl_db.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/strings.dart';

class AvailableForPage extends StatelessWidget {
  const AvailableForPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.unlock,
        title: translate.availableFor,
      ),
      body: const AvailableForPageBody(),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget:
            BlocBuilder<AvailableForCubit, AvailableForState>(
          builder: (context, state) => OkButton(
            onPressed: () => Navigator.of(context).maybePop(state),
          ),
        ),
      ),
    );
  }
}

class AvailableForPageBody extends StatelessWidget {
  const AvailableForPageBody({
    Key? key,
    this.onRadioButtonChanged,
    this.onSupportPersonChanged,
  }) : super(key: key);
  final Function? onRadioButtonChanged;
  final Function? onSupportPersonChanged;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<AvailableForCubit, AvailableForState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
                layout.templates.m3.left,
                layout.templates.m3.top,
                layout.templates.m3.right,
                layout.formPadding.verticalItemDistance),
            child: RadioField<AvailableForType>(
              groupValue: state.availableFor,
              onChanged: (value) => _onRadioButtonChanged(context, value),
              value: AvailableForType.onlyMe,
              leading: Icon(
                AbiliaIcons.lock,
                size: layout.icon.button,
              ),
              text: Text(translate.onlyMe),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: layout.templates.m3.left,
                right: layout.templates.m3.right,
                bottom: layout.formPadding.verticalItemDistance),
            child: RadioField<AvailableForType>(
              groupValue: state.availableFor,
              onChanged: (value) => _onRadioButtonChanged(context, value),
              value: AvailableForType.allSupportPersons,
              leading: Icon(
                AbiliaIcons.unlock,
                size: layout.icon.button,
              ),
              text: Text(translate.allSupportPersons),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                  left: layout.templates.m3.left,
                  right: layout.templates.m3.right,
                  bottom: layout.templates.m3.bottom),
              child: RadioField<AvailableForType?>(
                groupValue: state.availableFor,
                onChanged: (value) => _onRadioButtonChanged(context, value),
                value: AvailableForType.selectedSupportPersons,
                leading: Icon(
                  AbiliaIcons.selectedSupport,
                  size: layout.icon.button,
                ),
                text: Text(translate.selectedSupportPersons),
              )),
          if (state.availableFor == AvailableForType.selectedSupportPersons)
            Expanded(
              child: SupportPersonsWidget(
                onSupportPersonChanged: onSupportPersonChanged,
              ),
            ),
        ],
      ),
    );
  }

  void _onRadioButtonChanged(BuildContext context, AvailableForType? value) {
    if (value != null) {
      context.read<AvailableForCubit>().setAvailableFor(value);
      if (onRadioButtonChanged != null) {
        onRadioButtonChanged!(context, value);
      }
    }
  }
}

class SupportPersonsWidget extends StatelessWidget {
  const SupportPersonsWidget({Key? key, this.onSupportPersonChanged})
      : super(key: key);

  final Function? onSupportPersonChanged;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return ScrollArrows.vertical(
      controller: scrollController,
      child: BlocBuilder<AvailableForCubit, AvailableForState>(
        builder: (context, state) {
          return ListView(
            controller: scrollController,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  bottom: layout.templates.m3.top,
                ),
                child: const Divider(),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: layout.templates.m3.left,
                    right: layout.templates.m3.right),
                child: Tts(
                  child: Text(Translator.of(context).translate.supportPersons,
                      style: bodyText2.copyWith(color: AbiliaColors.black75)),
                ),
              ),
              ...state.allSupportPersons
                  .map(
                    (person) => SwitchField(
                      leading: ProfilePicture(
                        GetIt.I<BaseUrlDb>().baseUrl,
                        person.image,
                        initial: person.name.substring(0, 1).capitalize(),
                        size: layout.icon.normal,
                      ).pad(
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                      value: state.selectedSupportPersons.contains(person.id),
                      onChanged: (selected) =>
                          _onSupportPersonChanged(context, person.id, selected),
                      child: Text(person.name),
                    ).pad(
                      EdgeInsets.only(
                        left: layout.templates.m3.left,
                        top: layout.formPadding.verticalItemDistance,
                        right: layout.templates.m3.right,
                      ),
                    ),
                  )
                  .toList(),
            ],
          ).pad(EdgeInsets.only(bottom: layout.templates.m1.bottom));
        },
      ),
    );
  }

  void _onSupportPersonChanged(BuildContext context, int id, bool selected) {
    context.read<AvailableForCubit>().selectSupportPerson(id, selected);
    if (onSupportPersonChanged != null) {
      onSupportPersonChanged!(context, id, selected);
    }
  }
}
