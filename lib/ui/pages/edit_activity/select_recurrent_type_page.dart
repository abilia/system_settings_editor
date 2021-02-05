import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SelectRecurrentTypePage extends StatefulWidget {
  final bool allDaysVisible;
  final String heading;
  final IconData headingIcon;

  const SelectRecurrentTypePage({
    Key key,
    this.allDaysVisible = false,
    @required this.heading,
    @required this.headingIcon,
  }) : super(key: key);
  @override
  _SelectRecurrentTypePageState createState() =>
      _SelectRecurrentTypePageState();
}

class _SelectRecurrentTypePageState extends State<SelectRecurrentTypePage> {
  ApplyTo applyTo = ApplyTo.onlyThisDay;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        title: widget.heading,
        iconData: widget.headingIcon,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField(
              key: TestKey.onlyThisDay,
              leading: Icon(AbiliaIcons.day),
              text: Text(translate.onlyThisDay),
              value: ApplyTo.onlyThisDay,
              groupValue: applyTo,
              onChanged: _radioChanged,
            ),
            if (widget.allDaysVisible) SizedBox(height: 8.0),
            if (widget.allDaysVisible)
              RadioField(
                key: TestKey.allDays,
                leading: Icon(AbiliaIcons.month),
                text: Text(translate.allDays),
                value: ApplyTo.allDays,
                groupValue: applyTo,
                onChanged: _radioChanged,
              ),
            SizedBox(height: 8.0),
            RadioField(
              key: TestKey.thisDayAndForward,
              leading: Icon(AbiliaIcons.week),
              text: Text(translate.thisDayAndForward),
              value: ApplyTo.thisDayAndForward,
              groupValue: applyTo,
              onChanged: _radioChanged,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
          backNavigationWidget: CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: () => Navigator.of(context).pop(applyTo),
          )),
    );
  }

  void _radioChanged(v) => setState(() => {applyTo = v});
}
