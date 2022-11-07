import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class MEMOplannerLogoWithLoginProgress extends StatelessWidget {
  const MEMOplannerLogoWithLoginProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => SizedBox(
        width: layout.login.logoSize,
        height: layout.login.logoSize,
        child: state is LoginLoading
            ? const AbiliaProgressIndicator()
            : GestureDetector(
                onLongPress: () {
                  context.read<LoginCubit>().clearFailure();
                  showDialog(
                    context: context,
                    builder: (context) => const BackendSwitcherDialog(),
                  );
                },
                child: MEMOplannerLogo(
                  height: layout.login.logoHeight,
                ),
              ),
      ),
    );
  }
}

class MEMOplannerLogo extends StatelessWidget {
  const MEMOplannerLogo({
    required this.height,
    Key? key,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image(
        image: AssetImage(
          'assets/graphics/${Config.flavor.id}/logo.png',
        ),
      ),
    );
  }
}
