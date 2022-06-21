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
    this.onAvailableForChanged,
    this.onSupportPersonChanged,
  }) : super(key: key);
  final Function? onAvailableForChanged;
  final Function? onSupportPersonChanged;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<AvailableForCubit, AvailableForState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RadioField<AvailableForType>(
            groupValue: state.availableFor,
            onChanged: (value) => _onAvailableForChanged(context, value),
            value: AvailableForType.onlyMe,
            leading: Icon(
              AbiliaIcons.lock,
              size: layout.icon.button,
            ),
            text: Text(translate.onlyMe),
          ).pad(
            layout.templates.m1
                .copyWith(bottom: layout.formPadding.verticalItemDistance),
          ),
          RadioField<AvailableForType>(
            groupValue: state.availableFor,
            onChanged: (value) => _onAvailableForChanged(context, value),
            value: AvailableForType.allSupportPersons,
            leading: Icon(
              AbiliaIcons.unlock,
              size: layout.icon.button,
            ),
            text: Text(translate.allSupportPersons),
          ).pad(
            EdgeInsets.symmetric(horizontal: layout.templates.m1.left),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          RadioField<AvailableForType?>(
            groupValue: state.availableFor,
            onChanged: (value) => _onAvailableForChanged(context, value),
            value: AvailableForType.selectedSupportPersons,
            leading: Icon(
              AbiliaIcons.selectedSupport,
              size: layout.icon.button,
            ),
            text: Text(translate.selectedSupportPersons),
          ).pad(
            EdgeInsets.symmetric(horizontal: layout.templates.m1.left),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          if (state.availableFor ==
              AvailableForType.selectedSupportPersons) ...[
            Padding(
              padding: EdgeInsets.only(
                top: layout.formPadding.verticalItemDistance,
              ),
              child: const Divider(),
            ),
            Expanded(
              child: SupportPersonsWidget(
                onSupportPersonChanged: onSupportPersonChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onAvailableForChanged(BuildContext context, AvailableForType? value) {
    if (value != null) {
      context.read<AvailableForCubit>().setAvailableFor(value);
      onAvailableForChanged?.call(value);
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
              Tts(
                child: Text(
                  Translator.of(context).translate.supportPersons,
                  style: bodyText2.copyWith(color: AbiliaColors.black75),
                ),
              ).pad(
                layout.templates.m1.copyWith(bottom: 0),
              ),
              ...state.allSupportPersons
                  .map(
                    (person) => SwitchField(
                      leading: Center(
                        child: ProfilePicture(
                          GetIt.I<BaseUrlDb>().baseUrl,
                          person.image,
                          initial: person.name.substring(0, 1).capitalize(),
                          size: layout.icon.normal,
                        ),
                      ),
                      padding: layout.supportPerson.switchFieldPadding,
                      value: state.selectedSupportPersons.contains(person.id),
                      onChanged: (selected) =>
                          _onSupportPersonChanged(context, person.id),
                      child: Text(person.name),
                    ).pad(
                      EdgeInsets.only(
                        left: layout.templates.m1.left,
                        top: layout.formPadding.verticalItemDistance,
                        right: layout.templates.m1.right,
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

  void _onSupportPersonChanged(BuildContext context, int id) {
    context.read<AvailableForCubit>().toggleSupportPerson(id);
    onSupportPersonChanged?.call(id);
  }
}
