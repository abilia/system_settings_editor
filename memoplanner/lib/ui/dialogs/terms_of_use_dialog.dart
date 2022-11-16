import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class TermsOfUseDialog extends StatefulWidget {
  final TermsOfUseCubit termsOfUseCubit;
  final bool isMoreDialogs;
  final Function() onNext;

  const TermsOfUseDialog({
    required this.termsOfUseCubit,
    required this.isMoreDialogs,
    required this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  State<TermsOfUseDialog> createState() => _TermsOfUseDialogState();
}

class _TermsOfUseDialogState extends State<TermsOfUseDialog> {
  late bool _termsOfCondition;
  late bool _privacyPolicy;

  TermsOfUseCubit get termsOfUseCubit => widget.termsOfUseCubit;

  TermsOfUse get _termsOfUse => TermsOfUse(
      termsOfCondition: _termsOfCondition, privacyPolicy: _privacyPolicy);

  @override
  void initState() {
    final termsOfUse = termsOfUseCubit.state.termsOfUse;
    _termsOfCondition = termsOfUse.termsOfCondition;
    _privacyPolicy = termsOfUse.privacyPolicy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return WillPopScope(
      onWillPop: () async => false,
      child: ViewDialog(
        bodyPadding: layout.templates.m4,
        expanded: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInImage(
              fadeInDuration: const Duration(milliseconds: 50),
              fadeInCurve: Curves.linear,
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage(
                'assets/graphics/${Config.flavor.id}/logo.png',
              ),
            ),
            SizedBox(height: layout.starterSetDialog.imageHeadingDistance),
            Tts(
              child: Text(
                translate.welcomeMemoplanner,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: layout.starterSetDialog.headingBodyDistance),
            Tts(
              child: Text(
                translate.readAndAgree,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            SizedBox(height: layout.starterSetDialog.headingBodyDistance * 2),
            AcceptTermsSwitch(
              key: TestKey.acceptTermsOfUse,
              linkText: translate.termsOfUse,
              value: _termsOfCondition,
              url: translate.termsOfUseUrl,
              onChanged: (v) {
                setState(() {
                  _termsOfCondition = v;
                });
              },
            ),
            SizedBox(height: layout.formPadding.verticalItemDistance),
            AcceptTermsSwitch(
              key: TestKey.acceptPrivacyPolicy,
              linkText: translate.privacyPolicy,
              value: _privacyPolicy,
              url: translate.privacyPolicyUrl,
              onChanged: (v) {
                setState(() {
                  _privacyPolicy = v;
                });
              },
            ),
          ],
        ),
        backNavigationWidget: _navigationButton(translate.welcomeMemoplanner),
      ),
    );
  }

  Widget _navigationButton(String welcomeText) {
    final termsAccepted = _termsOfCondition && _privacyPolicy;
    final Function()? onPressed = termsAccepted ? postAndClose : null;
    if (widget.isMoreDialogs) {
      return NextButton(onPressed: onPressed);
    }
    return GreenButton(
      text: welcomeText,
      icon: AbiliaIcons.navigationNext,
      onPressed: onPressed,
    );
  }

  Future<void> postAndClose() async {
    await termsOfUseCubit.postTermsOfUse(_termsOfUse);
    return widget.onNext();
  }
}
