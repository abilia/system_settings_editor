import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(height: 68.0),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 32.0),
            ProfilePictureNameAndEmail(),
            Spacer(),
            LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class ProfilePictureNameAndEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) => FutureBuilder(
        future: state is Authenticated
            ? state.userRepository.me(state.token)
            : GetIt.I<UserDb>().getUser(),
        builder: (context, AsyncSnapshot<User> userSnapshot) => Column(
          children: <Widget>[
            ProfilePicture(
                state is AuthenticationInitialized
                    ? state.userRepository.baseUrl
                    : null,
                userSnapshot.data),
            SizedBox(height: 24.0),
            Text(
              userSnapshot.data?.name ?? '',
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(height: 4.0),
            Text(
              userSnapshot.data?.username ?? '',
              style: Theme.of(context)
                  .textTheme
                  .body2
                  .copyWith(color: AbiliaColors.black[75]),
            ),
          ],
        ),
      ),
    );
  }
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
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: AbiliaCloseButton(),
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
      ),
    );
  }
}
