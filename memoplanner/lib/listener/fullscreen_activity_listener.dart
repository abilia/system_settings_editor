import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';

import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FullscreenActivityListener extends StatelessWidget {
  final Widget child;

  const FullscreenActivityListener({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<FullScreenActivityCubit, FullScreenActivityState>(
      listenWhen: (previous, current) => current.eventsList?.isEmpty ?? false,
      listener: (context, s) => GetIt.I<AlarmNavigator>().popFullscreenRoute(),
      child: child,
    );
  }
}
