import 'package:seagull/ui/all.dart';

class RecurringMonthlyWiz extends StatelessWidget {
  const RecurringMonthlyWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.monthly,
        iconData: AbiliaIcons.month,
      ),
      body: Column(
        children: [
          ...[
            SizedBox(height: 24.s),
            MonthDays(),
            SizedBox(height: 16.s),
            Divider(),
            SizedBox(height: 24.s),
            EndDateWidget(),
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
      bottomNavigationBar: const WizardBottomNavigation(),
    );
  }
}
