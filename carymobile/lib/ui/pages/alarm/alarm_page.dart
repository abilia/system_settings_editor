import 'package:carymessenger/bloc/alarm_page_bloc.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:carymessenger/ui/themes/text_styles.dart';
import 'package:carymessenger/ui/widgets/abilia_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'play_stop_button.dart';
part 'alarm_page_listener.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AlarmPageBloc>().state;
    final activityDay = state.activityDay;
    final title = activityDay.title;
    final description = activityDay.activity.description;

    return AlarmPageListeners(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                if (activityDay.hasImage)
                  SizedBox(
                    height: 296,
                    child: AbiliaImage(activityDay.image),
                  ),
                if (title.isNotEmpty) Text(title, style: headline4),
                if (description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                if (state.hasExtraSound) const PlayStopButton(),
                ActionButtonGreen(
                  onPressed: Navigator.of(context).maybePop,
                  leading: const Icon(AbiliaIcons.ok),
                  text: 'Ok',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
