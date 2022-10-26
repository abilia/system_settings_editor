import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

typedef GetNowOffset = double Function(DateTime now);
typedef ScrollListenerWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController controller,
);

class CalendarScrollListener extends StatelessWidget {
  const CalendarScrollListener({
    required this.getNowOffset,
    required this.inViewMargin,
    required this.builder,
    this.timepillarMeasures,
    this.agendaEvents,
    this.enabled = true,
    this.disabledInitOffset,
    Key? key,
  }) : super(key: key);

  final ScrollListenerWidgetBuilder builder;
  final GetNowOffset getNowOffset;
  final double inViewMargin;
  final TimepillarMeasures? timepillarMeasures;
  final int? agendaEvents;
  final double? disabledInitOffset;
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
          ScrollController(initialScrollOffset: disabledInitOffset ?? 0),
        ),
      );
    }

    return _CalendarScrollListener(
      getNowOffset: getNowOffset,
      inViewMargin: inViewMargin,
      timepillarMeasures: timepillarMeasures,
      agendaEvents: agendaEvents,
      builder: builder,
    );
  }
}

class _CalendarScrollListener extends StatefulWidget {
  const _CalendarScrollListener({
    required this.getNowOffset,
    required this.inViewMargin,
    required this.builder,
    this.timepillarMeasures,
    this.agendaEvents,
    Key? key,
  }) : super(key: key);

  final GetNowOffset getNowOffset;
  final double inViewMargin;
  final ScrollListenerWidgetBuilder builder;
  final TimepillarMeasures? timepillarMeasures;
  final int? agendaEvents;

  @override
  State<_CalendarScrollListener> createState() =>
      _CalendarScrollListenerState();
}

class _CalendarScrollListenerState extends State<_CalendarScrollListener> {
  late final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateScrollState();
      if (mounted && context.read<DayPickerBloc>().state.isToday) {
        context.read<ScrollPositionCubit>().goToNow(duration: Duration.zero);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _CalendarScrollListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateScrollState();

      if (oldWidget.timepillarMeasures != widget.timepillarMeasures ||
          oldWidget.agendaEvents != widget.agendaEvents) {
        context.read<ScrollPositionCubit>()
          ..updateNowOffset(
            nowOffset: widget.getNowOffset(context.read<ClockBloc>().state),
          )
          ..goToNow(duration: Duration.zero);
      }
    });
  }

  void _updateScrollState() {
    final nowOffset = widget.getNowOffset(context.read<ClockBloc>().state);
    context.read<ScrollPositionCubit>().updateState(
          scrollController: controller,
          nowOffset: nowOffset,
          inViewMargin: widget.inViewMargin,
        );
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
          ? widget.builder(context, controller)
          : _AutoScrollToNow(
              getNowOffset: widget.getNowOffset,
              child: widget.builder(context, controller),
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