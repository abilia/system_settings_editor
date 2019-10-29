import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:seagull/bloc.dart';
import 'package:seagull/ui/components.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
          child: AbiliaButton(
          label: 'logout',
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
            Navigator.of(context).maybePop();
          },
        )),
    );
  }
}
