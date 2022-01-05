import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

/// copied from [showDialog]
Future<T?> showViewDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required List<BlocProvider>? authProviders,
  Color barrierColor = AbiliaColors.transparentBlack90,
  bool useSafeArea = true,
}) {
  return showDialog<T>(
    context: context,
    builder: authProviders != null
        ? (_) => MultiBlocProvider(
              providers: authProviders,
              child: Builder(builder: builder),
            )
        : builder,
    useSafeArea: useSafeArea,
    barrierColor: barrierColor,
  );
}
