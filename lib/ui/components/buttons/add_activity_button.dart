import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivityButton extends StatelessWidget {
  const AddActivityButton({
    Key key,
    @required this.day,
  }) : super(key: key);

  final DateTime day;

  @override
  Widget build(BuildContext context) => ActionButton(
        key: TestKey.addActivity,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: CreateActivityPage(day: day),
            ),
            settings: RouteSettings(name: 'CreateActivityPage'),
          ),
        ),
        child: Icon(AbiliaIcons.plus),
      );
}
