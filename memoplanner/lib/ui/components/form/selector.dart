import 'package:seagull/ui/all.dart';

class SelectorItem<T> {
  final String title;
  final IconData icon;
  final T? value;
  const SelectorItem(this.title, this.icon, [this.value]);
}

class Selector<T> extends StatelessWidget {
  final String? heading;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final List<SelectorItem> items;

  const Selector({
    required this.items,
    this.heading,
    this.groupValue,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heading = this.heading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading != null) ...[
          Center(
            child: Tts(
              child: Text(
                heading,
                style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
                    .copyWith(
                  color: AbiliaColors.black75,
                ),
              ),
            ),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance)
        ],
        Row(
          children: [
            for (int i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  right: i == items.length - 1
                      ? 0
                      : layout.formPadding.selectorDistance,
                ),
                child: _SelectButton<T>(
                  text: items[i].title,
                  onPressed: () => onChanged?.call(items[i].value),
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
      ],
    );
  }
}

class _SelectButton<T> extends StatelessWidget {
  final T? value;
  final T? groupValue;
  final String text;
  final IconData icon;
  final BorderRadius borderRadius;
  final VoidCallback? onPressed;

  const _SelectButton({
    required this.value,
    required this.text,
    required this.borderRadius,
    required this.icon,
    this.onPressed,
    this.groupValue,
    Key? key,
  }) : super(key: key);

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
          padding: MaterialStateProperty.all(
              EdgeInsets.only(bottom: layout.formPadding.verticalItemDistance)),
        ),
        child: Column(
          children: [
            Text(text),
            Icon(icon, size: layout.selector.iconSize),
          ],
        ),
      ),
    );
  }
}
