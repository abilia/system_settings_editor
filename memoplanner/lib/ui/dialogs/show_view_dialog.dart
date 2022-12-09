import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

/// copied from [showDialog]
Future<T?> showViewDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = AbiliaColors.transparentBlack90,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  bool wrapWithAuthProviders = true,
}) {
  final authProviders = wrapWithAuthProviders
      ? copiedAuthProviders(context)
      : [BlocProvider.value(value: context.read<SpeechSettingsCubit>())];
  return showDialog<T>(
    context: context,
    builder: (_) => MultiBlocProvider(
      providers: authProviders,
      child: Builder(builder: builder),
    ),
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
  );
}

Future<T?> showPersistentDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = AbiliaColors.transparentBlack90,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  bool wrapWithAuthProviders = true,
}) {
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );
  final authProviders = wrapWithAuthProviders
      ? copiedAuthProviders(context)
      : [BlocProvider.value(value: context.read<SpeechSettingsCubit>())];
  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(PersistentDialogRoute<T>(
    context: context,
    builder: (_) => MultiBlocProvider(
      providers: authProviders,
      child: Builder(builder: builder),
    ),
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    settings: routeSettings,
    themes: themes,
    anchorPoint: anchorPoint,
  ));
}
