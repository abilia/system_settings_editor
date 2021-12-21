import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimerNameAndPictureWidget extends StatelessWidget {
  const TimerNameAndPictureWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerWizardCubit, TimerWizardState>(
      builder: (context, state) {
        return NameAndPictureWidget(
          selectedImage: state.image,
          text: state.name,
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
          onImageSelected: (selectedImage) {
            BlocProvider.of<TimerWizardCubit>(context)
                .updateImage(selectedImage);
          },
          onTextEdit: (text) {
            if (state.name != text) {
              BlocProvider.of<TimerWizardCubit>(context).updateName(text);
            }
          },
        );
      },
    );
  }
}
