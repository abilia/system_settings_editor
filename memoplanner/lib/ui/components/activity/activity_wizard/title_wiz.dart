import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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
    controller =
        SpokenTextEditController.ifApplicable(context, text: activity.title);
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final appBar = AbiliaAppBar(
      iconData: AbiliaIcons.edit,
      label: Translator.of(context).translate.newActivity,
      title: t.enterNameForActivity,
      borderRadius: layout.appBar.borderRadius,
      useVerticalSafeArea: false,
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              textCapitalization: TextCapitalization.sentences,
                              style: Theme.of(context).textTheme.bodyText1,
                              autofocus: true,
                              focusNode: focusNode,
                              onChanged: (s) => context
                                  .read<EditActivityCubit>()
                                  .replaceActivity(activity.copyWith(title: s)),
                              maxLines: 1,
                              onSubmitted: (_) {
                                context.read<WizardCubit>().next();
                              },
                            ),
                          ),
                          TtsPlayButton(
                            controller: controller,
                            padding: EdgeInsets.only(
                              left: layout.defaultTextInputPage
                                  .textFieldActionButtonSpacing,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const WizardBottomNavigation(useVerticalSafeArea: false),
            ],
          ),
        ),
        bottomNavigationBar: null,
      ),
    );
  }
}
