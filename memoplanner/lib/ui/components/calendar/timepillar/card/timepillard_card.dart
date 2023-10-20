import 'package:memoplanner/ui/all.dart';

abstract class TimepillarCard extends StatelessWidget {
  static const int defaultTitleLines = 3;
  static const int maxTitleLines = 10;
  final int column;

  double get endPos => cardPosition.top + cardPosition.height;

  final CardPosition cardPosition;
  const TimepillarCard(
    this.column,
    this.cardPosition, {
    super.key,
  });
}
