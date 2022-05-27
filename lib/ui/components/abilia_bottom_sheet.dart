import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

Future<T?> showAbiliaBottomSheet<T>({
  required BuildContext context,
  required Widget child,
}) async {
  final authProviders = copiedAuthProviders(context);
  return await showModalBottomSheet<T>(
    backgroundColor: Colors.transparent,
    isDismissible: false,
    isScrollControlled: true,
    enableDrag: false,
    context: context,
    barrierColor: AbiliaColors.transparentBlack90,
    builder: (_) => MultiBlocProvider(
      providers: authProviders,
      child: child,
    ),
  );
}
