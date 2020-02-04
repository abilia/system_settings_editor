import 'dart:math';
import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/calendar/overlay/all.dart';

import 'all.dart';

class TimePillar extends StatefulWidget {
  const TimePillar({Key key}) : super(key: key);

  @override
  _TimePillarState createState() => _TimePillarState();
}

class _TimePillarState extends State<TimePillar> {
  ScrollController verticalScrollController;
  ScrollController horizontalScrollController;
  final scrollHeight = 1536.0;
  final timePillarWidth = 60.0;
  final center = ObjectKey('center');

  @override
  void didChangeDependencies() {
    double screenWidth = MediaQuery.of(context).size.width;
    verticalScrollController =
        ScrollController(initialScrollOffset: (scrollHeight / 2));
    horizontalScrollController = ScrollController(
        initialScrollOffset: -(screenWidth / 2) + (timePillarWidth / 2));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return SingleChildScrollView(
          controller: verticalScrollController,
          child: LimitedBox(
            maxHeight: scrollHeight,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              center: center,
              controller: horizontalScrollController,
              slivers: <Widget>[
                SliverLayoutBuilder(
                  builder: (context, sliverConstraints) {
                    return SliverOverlayBuilder(
                      height: boxConstraints.maxHeight,
                      builder: (context, state) {
                        return ScrollTranslated(
                          controller: verticalScrollController,
                          child: Stack(
                            children: <Widget>[
                              Placeholder(),
                              Category(
                                right: false,
                                child: Text(translate.left),
                              ),
                            ],
                          ),
                        );
                      },
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) =>
                              TileWidget(index),
                          childCount: 20,
                        ),
                      ),
                    );
                  },
                ),
                SliverTimePillar(
                  key: center,
                  child: Container(
                    width: timePillarWidth,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                          colors: colors, tileMode: TileMode.mirror),
                    ),
                  ),
                ),
                SliverOverlay(
                  height: boxConstraints.maxHeight,
                  overlay: ScrollTranslated(
                    controller: verticalScrollController,
                    child: Stack(
                      children: <Widget>[
                        Placeholder(),
                        Category(
                          right: true,
                          child: Text(translate.right),
                        ),
                      ],
                    ),
                  ),
                  sliver: SliverFillViewport(
                    viewportFraction: 0.1,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) => TileWidget(index),
                      childCount: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Category extends StatelessWidget {
  final Widget child;
  final bool right;
  const Category({
    Key key,
    this.child,
    this.right,
  }) : super(key: key);
  final radius = const Radius.circular(12);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18.0,
      left: right ? null : 0,
      right: right ? 0 : null,
      child: Container(
        width: 83,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: right
              ? BorderRadius.only(topLeft: radius, bottomLeft: radius)
              : BorderRadius.only(topRight: radius, bottomRight: radius),
          color: AbiliaColors.white[135],
        ),
        child: Container(
          decoration: BoxDecoration(),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class ScrollTranslated extends StatefulWidget {
  final ScrollController controller;
  final Widget child;

  const ScrollTranslated({Key key, this.controller, this.child})
      : super(key: key);
  @override
  _ScrollTranslatedState createState() => _ScrollTranslatedState();
}

class _ScrollTranslatedState extends State<ScrollTranslated> {
  double scrollOffset;
  @override
  void initState() {
    widget.controller.addListener(listener);
    scrollOffset =
        widget.controller.hasClients ? widget.controller.offset : 0.0;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0.0, scrollOffset), child: widget.child);
  }

  void listener() {
    if (widget.controller.offset != scrollOffset) {
      setState(() => scrollOffset = widget.controller.offset);
    }
  }
}

const colors = [
  Colors.amber,
  Colors.red,
  Colors.yellow,
  Colors.blue,
  Colors.teal,
  Colors.pink,
  Colors.orange
];

class TileWidget extends StatelessWidget {
  TileWidget(this.index, {Key key})
      : color = colors[index % colors.length],
        super(key: key);

  final int index;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    final color1 = color[max(index % 10 * 100, 50)];
    final color2 = color[max((index + 5) % 10 * 100, 50)];
    return Container(
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.center,
          end: Alignment.topCenter,
          tileMode: TileMode.mirror,
        ),
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: Center(
          child: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text('$index'),
      )),
    );
  }
}
