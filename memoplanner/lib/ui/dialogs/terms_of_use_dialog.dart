import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class TermsOfUseDialog extends StatefulWidget {
  final AuthenticatedDialogCubit loginDialogCubit;
  final bool isMoreDialogs;
  final Function() onNext;

  const TermsOfUseDialog({
    required this.loginDialogCubit,
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

  AuthenticatedDialogCubit get termsOfUseCubit => widget.loginDialogCubit;

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
              width: layout.termsOfUseDialog.imageSize,
              height: layout.termsOfUseDialog.imageSize,
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage(
                'assets/graphics/${Config.flavor.id}/logo.png',
              ),
            ),
            SizedBox(height: layout.termsOfUseDialog.imageHeadingDistance),
            Tts(
              child: Text(
                translate.welcomeMemoplanner,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: layout.termsOfUseDialog.headingTextDistance),
            Tts(
              child: Text(
                translate.readAndAgree,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            SizedBox(height: layout.termsOfUseDialog.bodyTextDistance),
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
        backNavigationWidget: _navigationButton(translate.openMemoplanner),
        backNavigationExpanded: true,
      ),
    );
  }

  Widget _navigationButton(String welcomeText) {
    final termsAccepted = _termsOfCondition && _privacyPolicy;
    final Function()? onPressed = termsAccepted ? saveAndClose : null;
    if (widget.isMoreDialogs) {
      return NextButton(
        onPressed: onPressed,
      );
    }
    return GreenButton(
      text: welcomeText,
      icon: AbiliaIcons.checkButton,
      onPressed: onPressed,
    );
  }

  Future<void> saveAndClose() async {
    termsOfUseCubit.saveTermsOfUse(_termsOfUse);
    return widget.onNext();
  }
}
