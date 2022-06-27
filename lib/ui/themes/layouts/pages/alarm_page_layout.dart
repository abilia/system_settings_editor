import 'package:seagull/ui/all.dart';

class AlarmPageLayout {
  final EdgeInsets clockPadding;

  const AlarmPageLayout({
    this.clockPadding = const EdgeInsets.only(right: 16),
  });
}

class AlarmPageLayoutMedium extends AlarmPageLayout {
  const AlarmPageLayoutMedium({
    EdgeInsets? clockPadding,
  }) : super(
          clockPadding: clockPadding ?? const EdgeInsets.only(right: 16),
        );
}

class AlarmPageLayoutLarge extends AlarmPageLayoutMedium {
  const AlarmPageLayoutLarge({
    EdgeInsets? clockPadding,
  }) : super(
          clockPadding: clockPadding ??
              const EdgeInsets.only(
                top: 16,
                bottom: 12,
                right: 5,
              ),
        );
}
