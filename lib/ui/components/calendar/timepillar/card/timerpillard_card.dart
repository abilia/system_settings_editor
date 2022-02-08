import 'package:seagull/ui/all.dart';

abstract class TimerpillarCard extends StatelessWidget {
  static const int maxTitleLines = 5;
  final int column;

  double get endPos => cardPosition.top + cardPosition.height;

  final CardPosition cardPosition;
  const TimerpillarCard(
    this.column,
    this.cardPosition, {
    Key? key,
  }) : super(key: key);
}
