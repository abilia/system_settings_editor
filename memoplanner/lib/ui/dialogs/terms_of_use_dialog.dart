import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:provider/provider.dart';

import 'package:memoplanner/bloc/authentication/authentication_bloc.dart';
import 'package:memoplanner/db/baseurl_db.dart';
import 'package:memoplanner/repository/all.dart';

class TermsOfUseDialog extends StatefulWidget {
  final TermsOfUse termsOfUse;
  final bool isMoreDialogs;
  final Function() onNext;

  const TermsOfUseDialog({
    required this.termsOfUse,
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

  @override
  void initState() {
    _termsOfCondition = widget.termsOfUse.termsOfCondition;
    _privacyPolicy = widget.termsOfUse.privacyPolicy;
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
                'Welcome to MEMOplanner 4',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: layout.starterSetDialog.headingBodyDistance),
            Tts(
              child: Text(
                'To use MEMOplanner 4, please read and agree to the terms of use and privacy policy',
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
        backNavigationWidget: _navigationWidget(),
      ),
    );
  }

  Widget _navigationWidget() {
    final termsAccepted = _termsOfCondition && _privacyPolicy;
    final Function()? onPressed = termsAccepted ? postAndClose : null;
    if (widget.isMoreDialogs) {
      return NextButton(onPressed: onPressed);
    }
    return GreenButton(
      text: 'Open MEMOplanner 4',
      icon: AbiliaIcons.navigationNext,
      onPressed: onPressed,
    );
  }

  Future<void> postAndClose() async {
    try {
      final success = await postTermsOfUse();
      if (success) {
        return widget.onNext();
      }
      //Todo: Indicate error
    } catch (error) {
      //Todo: Indicate error
    }
  }

  Future<bool> postTermsOfUse() async {
    final baseUrl = GetIt.I<BaseUrlDb>().baseUrl;
    final client = GetIt.I<ListenableClient>();
    final authenticatedState = context.read<AuthenticationBloc>().state;
    if (authenticatedState is! Authenticated) {
      throw UnauthorizedException();
    }
    final userId = authenticatedState.userId;

    final response = await client.post(
      '$baseUrl/api/v1//entity//$userId/acknowledgments'.toUri(),
      headers: jsonHeader,
      body: jsonEncode({
        'termsOfCondition': _termsOfCondition,
        'privacyPolicy': _privacyPolicy
      }),
    );
    if (response.statusCode == 200) return true;
    return false;
  }
}
