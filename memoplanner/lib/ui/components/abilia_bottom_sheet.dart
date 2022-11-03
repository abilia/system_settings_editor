import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

Future<T?> showAbiliaBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  List<BlocProvider>? providers,
}) async {
  return await showModalBottomSheet<T>(
    backgroundColor: Colors.transparent,
    isDismissible: false,
    isScrollControlled: true,
    enableDrag: false,
    context: context,
    barrierColor: AbiliaColors.transparentBlack90,
    builder: (_) => providers != null && providers.isNotEmpty
        ? MultiBlocProvider(
            providers: providers,
            child: child,
          )
        : child,
  );
}
