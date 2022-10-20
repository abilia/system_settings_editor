import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

typedef GetNowOffset = double Function(DateTime now);
typedef ScrollListenerWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController controller,
);

class ScrollListener extends StatelessWidget {
  const ScrollListener({
    required this.getNowOffset,
    required this.inViewMargin,
    required this.builder,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final ScrollListenerWidgetBuilder builder;
  final GetNowOffset getNowOffset;
  final double inViewMargin;
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
        child: builder(
          context,
          ScrollController(),
        ),
      );
    }

    return _ScrollListener(
      getNowOffset: getNowOffset,
      inViewMargin: inViewMargin,
      builder: builder,
    );
  }
}

class _ScrollListener extends StatefulWidget {
  const _ScrollListener({
    required this.getNowOffset,
    required this.inViewMargin,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final GetNowOffset getNowOffset;
  final double inViewMargin;
  final ScrollListenerWidgetBuilder builder;

  @override
  State<_ScrollListener> createState() => _ScrollListenerState();
}

class _ScrollListenerState extends State<_ScrollListener> {
  late final ScrollController controller = ScrollController();
  ScrollMetrics? scrollMetrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final nowOffset = widget.getNowOffset(context.read<ClockBloc>().state);
      context.read<ScrollPositionCubit>().updateState(
            scrollController: controller,
            nowOffset: nowOffset,
            inViewMargin: widget.inViewMargin,
          );

      if (mounted && context.read<DayPickerBloc>().state.isToday) {
        context.read<ScrollPositionCubit>().goToNow(duration: Duration.zero);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ScrollListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nowOffset = widget.getNowOffset(context.read<ClockBloc>().state);
    context.read<ScrollPositionCubit>().updateState(
          scrollController: controller,
          nowOffset: nowOffset,
          inViewMargin: widget.inViewMargin,
        );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollMetricNotification) {
        final previous = scrollMetrics;
        final current = scrollMetricNotification.metrics;

        if (previous != null &&
            (previous.viewportDimension != current.viewportDimension ||
                previous.maxScrollExtent != current.maxScrollExtent ||
                previous.minScrollExtent != current.minScrollExtent)) {
          context.read<ScrollPositionCubit>().updateNowOffset(
              nowOffset: widget.getNowOffset(context.read<ClockBloc>().state));
          context.read<ScrollPositionCubit>().goToNow(duration: Duration.zero);
        }

        scrollMetrics = current;
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.axis == Axis.vertical) {
            context.read<ScrollPositionCubit>().scrollPositionUpdated();
          }
          return false;
        },
        child: !Config.isMP
            ? widget.builder(context, controller)
            : _AutoScrollToNow(
                getNowOffset: widget.getNowOffset,
                child: widget.builder(context, controller),
              ),
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
