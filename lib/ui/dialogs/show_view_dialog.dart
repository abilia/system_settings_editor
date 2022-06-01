import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

/// copied from [showDialog]
Future<T?> showViewDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color barrierColor = AbiliaColors.transparentBlack90,
  bool useSafeArea = true,
  bool wrapWithAuthProviders = true,
}) {
  final authProviders =
      wrapWithAuthProviders ? copiedAuthProviders(context) : null;
  return showDialog<T>(
    context: context,
    builder: authProviders != null && authProviders.isNotEmpty
        ? (_) => MultiBlocProvider(
              providers: authProviders,
              child: Builder(builder: builder),
            )
        : builder,
    useSafeArea: useSafeArea,
    barrierColor: barrierColor,
  );
}
