import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

class MEMOplannerLogoHiddenBackendSwitch extends StatelessWidget {
  const MEMOplannerLogoHiddenBackendSwitch({
    super.key,
    this.loading = false,
    this.height,
  });
  final bool loading;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final height = this.height ?? layout.login.logoHeight;
    final backend =
        context.select((BaseUrlCubit cubit) => backendName(cubit.state));
    final widget = loading
        ? SizedBox(
            height: height,
            width: height,
            child: const AbiliaProgressIndicator(),
          )
        : GestureDetector(
            onLongPress: () async => showDialog(
              context: context,
              builder: (context) => const BackendSwitcherDialog(),
            ),
            child: MEMOplannerLogo(height: height),
          );
    if (backend == prodName || loading) return widget;

    return Banner(
      message: backend,
      location: BannerLocation.topStart,
      child: widget,
    );
  }
}

class MEMOplannerLogo extends StatelessWidget {
  const MEMOplannerLogo({
    required this.height,
    super.key,
  });

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
