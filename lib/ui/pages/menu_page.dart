import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/user_db.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MenuAppBar(height: 68.0),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
            final futureUser = state is Authenticated
                ? state.userRepository.me(state.token)
                : GetIt.I<UserDb>().getUser();
            return Column(
              children: <Widget>[
                SizedBox(height: 32.0),
                ProfilePicture(state, futureUser),
                SizedBox(height: 24.0),
                NameAndEmail(futureUser),
                Spacer(),
                LogoutButton(),
              ],
            );
          }),
        ),
      );
}

class NameAndEmail extends StatelessWidget {
  final Future<User> _futureUser;
  const NameAndEmail(this._futureUser, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _futureUser,
        builder: (context, AsyncSnapshot<User> snapshot) {
          return Column(
            children: <Widget>[
              Text(
                snapshot.data?.name ?? '',
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 4.0),
              Text(
                snapshot.data?.username ?? '',
                style: Theme.of(context)
                    .textTheme
                    .body2
                    .copyWith(color: AbiliaColors.black[75]),
              ),
            ],
          );
        },
      );
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: AbiliaColors.red,
      key: TestKey.loggInButton,
      child: Text(
        Translator.of(context).translate.logout,
        style: Theme.of(context)
            .textTheme
            .subhead
            .copyWith(color: AbiliaColors.white),
      ),
      onPressed: () {
        BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
        Navigator.of(context).maybePop();
      },
    );
  }
}

class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  const MenuAppBar({Key key, @required this.height}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.color,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: CloseButton(),
                ),
                Center(
                  child: Text(
                    Translator.of(context).translate.menu,
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: AbiliaColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
            buttonTheme: actionButtonTheme(context).copyWith(minWidth: 65)),
        child: FlatButton(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          color: AbiliaColors.transparantWhite[20],
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              width: 1,
              color: AbiliaColors.transparantWhite[10],
            ),
          ),
          child: Text(
            Translator.of(context).translate.close,
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      );
}
