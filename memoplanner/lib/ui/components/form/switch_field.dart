import 'package:memoplanner/ui/all.dart';

class SwitchField extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final Widget child;
  final String? ttsData;
  final double? heigth, width;
  final bool value;
  final Decoration? decoration;
  final EdgeInsets? padding;
  static final defaultHeight = layout.switchField.height;

  const SwitchField({
    required this.child,
    this.onChanged,
    this.leading,
    this.heigth,
    this.width,
    this.value = false,
    this.decoration,
    this.padding,
    this.ttsData,
    Key? key,
  })  : assert(child is Text || ttsData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: child is Text ? (child as Text).data : ttsData,
        toggled: value,
      ),
      child: InkWell(
        onTap: () => onChanged?.call(!value),
        borderRadius: borderRadius,
        child: Container(
          height: heigth ?? defaultHeight,
          width: width,
          decoration: onChanged == null
              ? boxDecoration
              : decoration ?? whiteBoxDecoration,
          padding: layout.switchField.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    if (leading != null) ...[
                      IconTheme(
                        data: Theme.of(context)
                            .iconTheme
                            .copyWith(size: layout.icon.small),
                        child: leading,
                      ),
                      SizedBox(
                        width: layout.formPadding.largeHorizontalItemDistance,
                      ),
                    ],
                    Expanded(
                      child: DefaultTextStyle(
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyLarge ?? bodyLarge,
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: layout.switchField.height,
                child: _MemoplannerSwitch(
                  value: value,
                  onToggle: (val) {
                    onChanged?.call(val);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoplannerSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onToggle;

  const _MemoplannerSwitch({
    required this.value,
    required this.onToggle,
  });

  @override
  _MemoplannerSwitchState createState() => _MemoplannerSwitchState();
}

class _MemoplannerSwitchState extends State<_MemoplannerSwitch>
    with SingleTickerProviderStateMixin {
  late final Animation _toggleAnimation;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
    );
    _toggleAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MemoplannerSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    _toggleAnimationController();
  }

  @override
  Widget build(BuildContext context) {
    final switchLayout = layout.switchField.switchLayout;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: switchLayout.width,
          child: Align(
            child: GestureDetector(
              onTap: () {
                _toggleAnimationController();
                widget.onToggle(!widget.value);
              },
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: switchLayout.height,
                      width: switchLayout.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: widget.value
                            ? AbiliaColors.green.withOpacity(0.38)
                            : AbiliaColors.black.withOpacity(0.38),
                      ),
                    ),
                  ),
                  Align(
                    alignment: _toggleAnimation.value,
                    child: Container(
                      width: switchLayout.thumbSize,
                      height: switchLayout.thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: kElevationToShadow[2],
                        color: widget.value
                            ? AbiliaColors.green
                            : AbiliaColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleAnimationController() {
    if (widget.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
