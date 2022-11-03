import 'package:memoplanner/ui/all.dart';

abstract class TimepillarCard extends StatelessWidget {
  static const int maxTitleLines = 5;
  final int column;

  double get endPos => cardPosition.top + cardPosition.height;

  final CardPosition cardPosition;
  const TimepillarCard(
    this.column,
    this.cardPosition, {
    Key? key,
  }) : super(key: key);
}
