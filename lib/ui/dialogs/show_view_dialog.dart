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
  bool barrierDismissible = true,
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
    useSafeArea: useSafeArea,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
  );
}
