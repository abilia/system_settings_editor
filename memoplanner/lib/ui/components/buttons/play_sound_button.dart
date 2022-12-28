import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/bloc/all.dart';

class PlaySoundButton extends StatefulWidget {
  final AbiliaFile sound;
  final ButtonStyle? buttonStyle;

  const PlaySoundButton({
    required this.sound,
    this.buttonStyle,
    Key? key,
  }) : super(key: key);

  @override
  State<PlaySoundButton> createState() => _PlaySoundButtonState();
}

class _PlaySoundButtonState extends State<PlaySoundButton> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    final soundBloc = context.read<SoundBloc>();
    soundBloc.add(const StopSound());
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SoundBloc, SoundState, bool>(
        selector: (state) =>
            state is SoundPlaying && state.currentSound == widget.sound,
        builder: (context, isPlaying) => IconActionButton(
          style: widget.buttonStyle ?? actionButtonStyleDark,
          onPressed: () => isPlaying
              ? context.read<SoundBloc>().add(const StopSound())
              : context.read<SoundBloc>().add(PlaySound(widget.sound)),
          child: Icon(
            isPlaying ? AbiliaIcons.stop : AbiliaIcons.playSound,
          ),
        ),
      );
}
