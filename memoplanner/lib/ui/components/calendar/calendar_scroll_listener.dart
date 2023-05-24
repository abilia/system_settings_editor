import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

typedef GetNowOffset = double Function(DateTime now);
typedef ScrollListenerWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController verticalController,
  ScrollController horizontalController,
);

class CalendarScrollListener extends StatelessWidget {
  const CalendarScrollListener({
    required this.getNowOffset,
    required this.builder,
    this.timepillarMeasures,
    this.agendaEvents,
    this.enabled = true,
    this.disabledInitOffset,
    Key? key,
  }) : super(key: key);

  final ScrollListenerWidgetBuilder builder;
  final GetNowOffset getNowOffset;
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
          SnapToCenterScrollController(),
        ),
      );
    }

    return _CalendarScrollListener(
      getNowOffset: getNowOffset,
      timepillarMeasures: timepillarMeasures,
      agendaEvents: agendaEvents,
      builder: builder,
    );
  }
}

class _CalendarScrollListener extends StatefulWidget {
  const _CalendarScrollListener({
    required this.getNowOffset,
    required this.builder,
    this.timepillarMeasures,
    this.agendaEvents,
    Key? key,
  }) : super(key: key);

  final GetNowOffset getNowOffset;
  final ScrollListenerWidgetBuilder builder;
  final TimepillarMeasures? timepillarMeasures;
  final int? agendaEvents;

  @override
  State<_CalendarScrollListener> createState() =>
      _CalendarScrollListenerState();
}

class _CalendarScrollListenerState extends State<_CalendarScrollListener>
    with WidgetsBindingObserver {
  final verticalController = ScrollController();
  final horizontalController = SnapToCenterScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        _updateScrollState();
        if (mounted && context.read<DayPickerBloc>().state.isToday) {
          await context
              .read<ScrollPositionCubit>()
              .goToNow(duration: Duration.zero);
        }
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _updateScrollState();
      await context.read<ScrollPositionCubit>().goToNow();
    }
  }

  @override
  void didUpdateWidget(covariant _CalendarScrollListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      _updateScrollState();

      if (oldWidget.timepillarMeasures != widget.timepillarMeasures ||
          oldWidget.agendaEvents != widget.agendaEvents) {
        final scrollPositionCubit = context.read<ScrollPositionCubit>()
          ..updateNowOffset(
            nowOffset: widget.getNowOffset(context.read<ClockBloc>().state),
          );
        await scrollPositionCubit.goToNow(duration: Duration.zero);
      }
    });
  }

  void _updateScrollState() {
    final nowOffset = widget.getNowOffset(context.read<ClockBloc>().state);
    context.read<ScrollPositionCubit>().updateState(
          scrollController: verticalController,
          nowOffset: nowOffset,
        );
  }

  @override
  Widget build(BuildContext context) {
    return !Config.isMP
        ? widget.builder(context, verticalController, horizontalController)
        : _AutoScrollToNow(
            getNowOffset: widget.getNowOffset,
            child: widget.builder(
              context,
              verticalController,
              horizontalController,
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

  Future<void> _scrollToNow(BuildContext context) async {
    await context.read<ScrollPositionCubit>().goToNow(
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
      listener: (context, _) async => _scrollToNow(context),
      child: BlocListener<ClockBloc, DateTime>(
        listener: (context, now) async {
          final scrollState = context.read<ScrollPositionCubit>().state;
          if (scrollState is! ScrollPositionReady) {
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
            await _scrollToNow(context);
          }
        },
        child: child,
      ),
    );
  }
}
