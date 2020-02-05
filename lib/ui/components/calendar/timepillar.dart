import 'dart:math';
import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/calendar/all.dart';

class TimePillar extends StatelessWidget {
  const TimePillar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalHeight = 1536.0;
    final timePillarWidth = 60.0;
    final center = ObjectKey('center');
    final halfScreenWidth = MediaQuery.of(context).size.width / 2;
    final halfScreenHeigth = MediaQuery.of(context).size.height / 2;

    return SingleChildScrollView(
      controller: ScrollController(
          initialScrollOffset: (totalHeight / 2) - halfScreenHeigth),
      child: SizedBox(
        height: totalHeight,
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          center: center,
          controller: ScrollController(initialScrollOffset: -halfScreenWidth),
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => TileWidget(index),
                childCount: 20,
              ),
            ),
            SliverTimePillar(
              key: center,
              child: Container(
                width: timePillarWidth,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                        colors: colors, tileMode: TileMode.mirror)),
              ),
            ),
            SliverFillViewport(
              viewportFraction: 0.1,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) { 
                  return TileWidget(index);
                },
                childCount: 50,
              ),
            ),
          ],
        ),
      ),
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
