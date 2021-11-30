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
    activity = context.read<EditActivityBloc>().state.activity;
    controller = TextEditingController(text: activity.title);
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocListener<ActivityWizardCubit, ActivityWizardState>(
      listener: (context, state) {
        if (state.currentStep == WizardStep.title) {
          focusNode.requestFocus();
        } else {
          focusNode.unfocus();
        }
      },
      child: WizardScaffold(
        title: t.enterNameForActivity,
        iconData: AbiliaIcons.edit,
        body: Tts.fromSemantics(
          SemanticsProperties(label: t.name),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: ordinaryPadding,
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
                          .read<EditActivityBloc>()
                          .add(ReplaceActivity(activity.copyWith(title: s))),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const WizardBottomNavigation(),
            ],
          ),
        ),
        bottomNavigationBar: null,
      ),
    );
  }
}