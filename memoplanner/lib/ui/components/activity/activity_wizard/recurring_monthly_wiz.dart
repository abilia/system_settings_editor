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
              SizedBox(height: layout.formPadding.groupTopDistance),
              const MonthDays(),
              SizedBox(height: layout.formPadding.groupBottomDistance),
              const Divider(),
              SizedBox(height: layout.formPadding.groupTopDistance),
              const EndDateWizWidget(),
            ].map(
              (w) => w is Divider
                  ? w
                  : Padding(
                      padding: layout.templates.s4,
                      child: w,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
