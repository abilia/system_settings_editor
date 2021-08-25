// @dart=2.9

import 'package:seagull/ui/all.dart';

class SelectorItem<T> {
  final String title;
  final IconData icon;
  final T value;
  const SelectorItem(this.title, this.icon, [this.value])
      : assert(title != null),
        assert(icon != null);
}

class Selector<T> extends StatelessWidget {
  final String heading;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final List<SelectorItem> items;

  const Selector({
    Key key,
    this.heading,
    this.groupValue,
    this.onChanged,
    @required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading != null) ...[
          Center(
            child: Tts(
              child: Text(
                heading,
                style: abiliaTextTheme.bodyText2.copyWith(
                  color: AbiliaColors.black75,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.s)
        ],
        Container(
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Padding(
                  padding:
                      EdgeInsets.only(right: i == items.length - 1 ? 0 : 2.s),
                  child: _SelectButton<T>(
                    text: items[i].title,
                    onPressed: () => onChanged(items[i].value),
                    groupValue: groupValue,
                    value: items[i].value,
                    borderRadius: i == 0
                        ? borderRadiusLeft
                        : i == items.length - 1
                            ? borderRadiusRight
                            : BorderRadius.zero,
                    icon: items[i].icon,
                  ),
                )
            ].map((e) => Expanded(child: e)).toList(),
          ),
        ),
      ],
    );
  }
}

class _SelectButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String text;
  final IconData icon;
  final BorderRadius borderRadius;
  final VoidCallback onPressed;

  const _SelectButton({
    @required this.onPressed,
    @required this.value,
    @required this.groupValue,
    @required this.text,
    @required this.borderRadius,
    @required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data: text,
      child: TextButton(
        onPressed: onPressed,
        style: tabButtonStyle(
          borderRadius: borderRadius,
          isSelected: value == groupValue,
        ).copyWith(
          textStyle: MaterialStateProperty.all(abiliaTextTheme.subtitle2),
          padding: MaterialStateProperty.all(EdgeInsets.only(bottom: 8.0.s)),
        ),
        child: Column(
          children: [
            Text(text),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}
