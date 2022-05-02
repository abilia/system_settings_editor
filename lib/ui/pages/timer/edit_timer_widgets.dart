import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TimerNamePictureAndTimeWidget extends StatelessWidget {
  const TimerNamePictureAndTimeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTimerCubit, EditTimerState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectPictureWidget(
                  selectedImage: state.image,
                  isLarge: true,
                  onImageSelected: (selectedImage) {
                    BlocProvider.of<EditTimerCubit>(context)
                        .updateImage(selectedImage);
                  },
                ),
                SizedBox(width: layout.formPadding.largeVerticalItemDistance),
                Expanded(
                  child: Column(
                    children: [
                      NameInput(
                        key: TestKey.timerNameText,
                        text: state.name,
                        onEdit: (text) {
                          if (state.name != text) {
                            BlocProvider.of<EditTimerCubit>(context)
                                .updateName(text);
                          }
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        inputHeading:
                            Translator.of(context).translate.enterNameForTimer,
                      ),
                      SizedBox(height: layout.formPadding.verticalItemDistance),
                      PickField(
                        onTap: () async {
                          final authProviders = copiedAuthProviders(context);
                          final duration =
                              await Navigator.of(context).push<Duration>(
                            MaterialPageRoute(
                              builder: (_) => MultiBlocProvider(
                                providers: authProviders,
                                child: EditTimerDurationPage(
                                  initialDuration: state.duration,
                                ),
                              ),
                            ),
                          );
                          if (duration != null) {
                            context
                                .read<EditTimerCubit>()
                                .updateDuration(duration);
                          }
                        },
                        leading: const Icon(AbiliaIcons.clock),
                        text: Text(
                          state.duration
                              .toString()
                              .split('.')
                              .first
                              .padLeft(8, '0'),
                        ),
                        trailing: PickField.trailingArrow,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
