import 'package:seagull/bloc/providers.dart';
import 'package:seagull/ui/all.dart';

class HiddenSetting extends StatefulWidget {
  const HiddenSetting(this.showCategories, {Key key}) : super(key: key);
  final bool showCategories;

  @override
  _HiddenSettingState createState() => _HiddenSettingState();
}

class _HiddenSettingState extends State<HiddenSetting> {
  bool rightTapped = false, leftTapped = false;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: widget.showCategories ? 50.s : 4.s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!leftTapped) {
                  leftTapped = true;
                  rightTapped = false;
                } else if (rightTapped) {
                  leftTapped = false;
                  rightTapped = false;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CopiedAuthProviders(
                        blocContext: context,
                        child: SettingsPage(),
                      ),
                      settings: RouteSettings(name: 'SettingsPage from hidden'),
                    ),
                  );
                }
              },
              child: SizedBox(
                width: actionButtonMinSize,
                height: actionButtonMinSize,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (leftTapped && !rightTapped) {
                  rightTapped = true;
                } else if (rightTapped) {
                  leftTapped = false;
                  rightTapped = false;
                }
              },
              child: SizedBox(
                width: actionButtonMinSize,
                height: actionButtonMinSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
