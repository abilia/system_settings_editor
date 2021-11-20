import 'package:seagull/ui/all.dart';

class RecurringMonthlyWiz extends StatelessWidget {
  const RecurringMonthlyWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return WizardScaffold(
      title: Translator.of(context).translate.monthly,
      iconData: AbiliaIcons.month,
      body: ArrowScrollable.verticalScrollArrows(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            ...[
              SizedBox(height: 24.s),
              const MonthDays(),
              SizedBox(height: 16.s),
              const Divider(),
              SizedBox(height: 24.s),
              const EndDateWizWidget(),
            ].map(
              (w) => w is Divider
                  ? w
                  : Padding(
                      padding: EdgeInsets.only(left: 12.s, right: 16.s),
                      child: w,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
