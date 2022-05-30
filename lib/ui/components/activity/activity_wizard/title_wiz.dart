import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class TitleWiz extends StatefulWidget {
  const TitleWiz({Key? key}) : super(key: key);

  @override
  State<TitleWiz> createState() => _TitleWizState();
}

class _TitleWizState extends StateWithFocusOnResume<TitleWiz> {
  late final Activity activity;
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    activity = context.read<EditActivityCubit>().state.activity;
    controller = TextEditingController(text: activity.title);
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final appBar = AbiliaAppBar(
      iconData: AbiliaIcons.edit,
      label: Translator.of(context).translate.newActivity,
      title: t.enterNameForActivity,
      borderRadius: layout.appBar.borderRadius,
    );

    return BlocListener<WizardCubit, WizardState>(
      listener: (context, state) {
        if (state.currentStep == WizardStep.title) {
          focusNode.requestFocus();
        } else {
          focusNode.unfocus();
        }
      },
      child: WizardScaffold(
        backgroundColor: AbiliaColors.black,
        showAppBar: false,
        title: t.enterNameForActivity,
        iconData: AbiliaIcons.edit,
        body: Tts.fromSemantics(
          SemanticsProperties(label: t.name),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: appBar.preferredSize.height,
                child: appBar,
              ),
              Container(
                color: AbiliaColors.white110,
                child: Padding(
                  padding: layout.templates.m1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SubHeading(t.name),
                      TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        style: Theme.of(context).textTheme.bodyText1,
                        autofocus: true,
                        focusNode: focusNode,
                        onChanged: (s) => context
                            .read<EditActivityCubit>()
                            .replaceActivity(activity.copyWith(title: s)),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const WizardBottomNavigation(),
            ],
          ),
        ),
        bottomNavigationBar: null,
      ),
    );
  }
}
