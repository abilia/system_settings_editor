import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SelectRecurrencePage extends StatefulWidget {
  final RecurrentType recurrentType;

  const SelectRecurrencePage({Key? key, required this.recurrentType})
      : super(key: key);

  @override
  _SelectRecurrencePageState createState() => _SelectRecurrencePageState();
}

class _SelectRecurrencePageState extends State<SelectRecurrencePage> {
  late RecurrentType newType;

  @override
  void initState() {
    super.initState();
    newType = widget.recurrentType;
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.recurrence,
        iconData: AbiliaIcons.repeat,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.0.s,
          vertical: 24.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...[
              RecurrentType.none,
              RecurrentType.weekly,
              RecurrentType.monthly,
              RecurrentType.yearly
            ].map(
              (type) => Padding(
                padding: EdgeInsets.only(bottom: 8.0.s),
                child: RadioField<RecurrentType>(
                  groupValue: newType,
                  onChanged: (v) {
                    if (v != null) setState(() => newType = v);
                  },
                  value: type,
                  leading: Icon(type.iconData()),
                  text: Text(type.text(translate)),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).maybePop(newType),
        ),
      ),
    );
  }
}
