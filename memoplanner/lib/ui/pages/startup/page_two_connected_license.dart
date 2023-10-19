import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class PageTwoConnectedLicense extends StatefulWidget {
  const PageTwoConnectedLicense({
    required this.pageController,
    required this.licenseNumberController,
    super.key,
  });

  final PageController pageController;
  final TextEditingController licenseNumberController;

  @override
  State<PageTwoConnectedLicense> createState() =>
      _PageTwoConnectedLicenseState();
}

class _PageTwoConnectedLicenseState extends State<PageTwoConnectedLicense> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_pageListener);
    widget.licenseNumberController.addListener(_inputListener);
  }

  void _pageListener() {
    final page = widget.pageController.page;
    if (page == 1 || page == 3) _focusNode.unfocus();
  }

  void _inputListener() {
    context
        .read<ConnectLicenseBloc>()
        .add(widget.licenseNumberController.text.replaceAll(RegExp(r'\D'), ''));
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_pageListener);
    widget.licenseNumberController.removeListener(_inputListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocBuilder<ConnectLicenseBloc, ConnectLicenseState>(
      builder: (context, state) => Padding(
        padding: layout.templates.m7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MEMOplannerLogoHiddenBackendSwitch(
              loading: state is ConnectingLicense,
            ),
            SizedBox(height: layout.startupPage.logoDistance),
            Tts(
              child: Text(
                '${translate.step} 2/3',
                style: abiliaTextTheme.bodyMedium
                    ?.copyWith(color: AbiliaColors.black75),
              ),
            ),
            SizedBox(height: layout.formPadding.smallVerticalItemDistance),
            Tts(
              child: Text(
                translate.enterYourLicense,
                style: abiliaTextTheme.titleLarge
                    ?.copyWith(color: AbiliaColors.black75),
              ),
            ),
            SizedBox(height: layout.startupPage.textPickDistance),
            SizedBox(
              width: layout.startupPage.contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    readOnly: state is SuccessfullyConnectedLicense ||
                        state is ConnectingLicense,
                    focusNode: _focusNode,
                    autofocus: state is! SuccessfullyConnectedLicense,
                    decoration: state is ConnectingLicenseFailed
                        ? inputErrorDecoration.copyWith(
                            border: redOutlineInputBorder,
                            focusedBorder: redOutlineInputBorder,
                          )
                        : state is SuccessfullyConnectedLicense
                            ? InputDecoration(
                                border: greenOutlineInputBorder,
                                focusedBorder: greenOutlineInputBorder,
                                disabledBorder: greenOutlineInputBorder,
                                enabledBorder: greenOutlineInputBorder,
                                suffixIcon: const Icon(
                                  AbiliaIcons.radioCheckboxSelected,
                                  color: AbiliaColors.green,
                                ),
                              )
                            : licenseInputDecoration(context),
                    controller: widget.licenseNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LicenseNumberFormatter(),
                    ],
                  ),
                  SizedBox(
                      height: layout.formPadding.smallVerticalItemDistance),
                  if (state is SuccessfullyConnectedLicense)
                    Text(
                      state.hasEndTime
                          ? '${translate.licenseValidDate}: '
                              '${DateFormat('yyyy-MM-dd').format(state.endTime)}'
                          : '',
                    )
                  else if (state is! ConnectingLicenseFailed)
                    Text(translate.enterYourLicenseHint)
                  else if (state.reason.notFoundOrWrongLicense)
                    Text(
                      translate.licenseErrorNotFound,
                      style: DefaultTextStyle.of(context).style.copyWith(
                            color: AbiliaColors.red,
                          ),
                    )
                  else if (state.reason.alreadyInuUse)
                    Text(
                      translate.licenseErrorAlreadyInUse,
                      style: DefaultTextStyle.of(context).style.copyWith(
                            color: AbiliaColors.red,
                          ),
                    )
                  else if (state.reason.noInternet)
                    const NoInternetErrorMessage(),
                ],
              ),
            ),
            SizedBox(height: layout.startupPage.textPickDistance),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: layout.startupPage.pageTwoButtonWidth,
                  child: IconAndTextButton(
                    onPressed: () async => widget.pageController.previousPage(
                      duration: StartupGuidePage.pageDuration,
                      curve: StartupGuidePage.curve,
                    ),
                    text: translate.previous,
                    style: textButtonStyleDarkGrey,
                    icon: AbiliaIcons.navigationPrevious,
                  ),
                ),
                SizedBox(width: layout.formPadding.horizontalItemDistance),
                SizedBox(
                  width: layout.startupPage.pageTwoButtonWidth,
                  child: TextButton(
                    key: TestKey.nextWelcomeGuide,
                    style: textButtonStyleGreen,
                    onPressed: state is SuccessfullyConnectedLicense
                        ? () async => widget.pageController.nextPage(
                              duration: StartupGuidePage.pageDuration,
                              curve: StartupGuidePage.curve,
                            )
                        : null,
                    child: Text(Lt.of(context).next),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LicenseNumberFormatter extends TextInputFormatter {
  final String separator;
  final int length, batches;

  LicenseNumberFormatter({
    this.separator = ' ',
    this.length = licenseLength,
    this.batches = 4,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length > newValue.text.length &&
        oldValue.text.endsWith(separator) &&
        !newValue.text.endsWith(separator)) {
      final newText = newValue.text.substring(0, newValue.text.length - 1);
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
        composing: TextRange.empty,
      );
    }
    final value = FilteringTextInputFormatter.digitsOnly
        .formatEditUpdate(oldValue, newValue);
    final digits = value.text;
    final divisions = digits.length ~/ batches;
    final newText = [
      ...[
        for (int i = 0; i < divisions; i++)
          digits.substring(i * batches, (i + 1) * batches)
      ],
      digits.substring(divisions * batches)
    ].join(separator);

    return LengthLimitingTextInputFormatter(length + divisions - 1)
        .formatEditUpdate(
      oldValue,
      value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
        composing: TextRange.empty,
      ),
    );
  }
}
