import 'package:seagull/ui/all.dart';

class RecurringMonthlyWiz extends StatelessWidget {
  const RecurringMonthlyWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return WizardScaffold(
      title: Translator.of(context).translate.monthly,
      iconData: AbiliaIcons.month,
      body: ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            ...[
              SizedBox(height: layout.formPadding.dividerBottomDistance),
              const MonthDays(),
              SizedBox(height: layout.formPadding.dividerTopDistance),
              const Divider(),
              SizedBox(height: layout.formPadding.dividerBottomDistance),
              const EndDateWizWidget(),
            ].map(
              (w) => w is Divider
                  ? w
                  : Padding(
                      padding: s3Padding,
                      child: w,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
