import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/generated/l10n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_to_speech/tts_handler.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/components/combo_box.dart';
import 'package:ui/components/helper_box.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/utils/states.dart';

part 'login_button.dart';

part 'login_form.dart';

part 'login_inputs.dart';

part 'logo_with_change_server.dart';

part 'welcome_to_handi_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    return BlocProvider(
      create: (context) => LoginCubit(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        pushService: GetIt.I<FirebasePushService>(),
        clockCubit: context.read<ClockCubit>(),
        userRepository: context.read<UserRepository>(),
        database: GetIt.I<Database>(),
        allowExpiredLicense: false,
        product: Product.handicalendar,
      ),
      child: Scaffold(
        backgroundColor: abiliaTheme.colors.surface.tertiary,
        body: const LoginForm(),
      ),
    );
  }
}
