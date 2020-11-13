import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AbiliaColors.white110,
      child: FlareActor(
        'assets/animation/MPGO.flr',
        alignment: Alignment.center,
        fit: BoxFit.contain,
        animation: 'v.2',
      ),
    );
  }
}
