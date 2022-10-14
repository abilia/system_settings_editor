import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

typedef GetNowOffset = double Function(DateTime now);

class ScrollListener extends StatelessWidget {
  const ScrollListener({
    required this.scrollController,
    required this.getNowOffset,
    required this.inViewMargin,
    required this.child,
    this.timepillarMeasures,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;
  final GetNowOffset getNowOffset;
  final double inViewMargin;
  final Widget child;
  final TimepillarMeasures? timepillarMeasures;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return BlocListener<DayPickerBloc, DayPickerState>(
        listenWhen: (previous, current) {
          return !previous.isToday && current.isToday;
        },
        listener: (context, state) {
          context.read<ScrollPositionCubit>().reset();
        },
        child: child,
      );
    }

    return _ScrollListener(
      scrollController: scrollController,
      getNowOffset: getNowOffset,
      inViewMargin: inViewMargin,
      timepillarMeasures: timepillarMeasures,
      child: child,
    );
  }
}

class _ScrollListener extends StatefulWidget {
  const _ScrollListener({
    required this.scrollController,
    required this.getNowOffset,
    required this.inViewMargin,
    required this.child,
    this.timepillarMeasures,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;
  final GetNowOffset getNowOffset;
  final double inViewMargin;
  final Widget child;
  final TimepillarMeasures? timepillarMeasures;

  @override
  State<_ScrollListener> createState() => _ScrollListenerState();
}

class _ScrollListenerState extends State<_ScrollListener> {
  @override
  void initState() {
    super.initState();
    _updateScrollState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<DayPickerBloc>().state.isToday) {
        context.read<ScrollPositionCubit>().goToNow();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ScrollListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateScrollState();
    if (oldWidget.timepillarMeasures != widget.timepillarMeasures) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ScrollPositionCubit>().scrollPositionUpdated();
          context.read<ScrollPositionCubit>().goToNow();
        }
      });
    }
  }

  void _updateScrollState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final nowOffset = widget.getNowOffset(context.read<ClockBloc>().state);

      context.read<ScrollPositionCubit>().updateState(
            scrollController: widget.scrollController,
            nowOffset: nowOffset,
            inViewMargin: widget.inViewMargin,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          context.read<ScrollPositionCubit>().scrollPositionUpdated();
        }
        return false;
      },
      child: !Config.isMP
          ? widget.child
          : _AutoScrollToNow(
              getNowOffset: widget.getNowOffset,
              child: widget.child,
            ),
    );
  }
}

class _AutoScrollToNow extends StatelessWidget {
  const _AutoScrollToNow({
    required this.child,
    required this.getNowOffset,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final GetNowOffset getNowOffset;

  void _scrollToNow(BuildContext context) {
    context.read<ScrollPositionCubit>().goToNow(
          duration: transitionDuration,
          curve: Curves.linear,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InactivityCubit, InactivityState>(
      listenWhen: (previous, current) {
        return previous is! ReturnToTodayState && current is ReturnToTodayState;
      },
      listener: (context, _) => _scrollToNow(context),
      child: BlocListener<ClockBloc, DateTime>(
        listener: (context, now) {
          final scrollState = context.read<ScrollPositionCubit>().state;
          if (scrollState is! ScrollPositionReadyState) {
            return;
          }

          final nowOffset = getNowOffset(now);
          context.read<ScrollPositionCubit>().updateNowOffset(
                nowOffset: nowOffset,
              );

          final isToday = context.read<DayPickerBloc>().state.isToday;
          final inactivityState = context.read<InactivityCubit>().state;
          final scrollToNow = isToday && inactivityState is! SomethingHappened;

          if (scrollToNow) {
            _scrollToNow(context);
          }
        },
        child: child,
      ),
    );
  }
}
