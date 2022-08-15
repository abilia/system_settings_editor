import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class EditImageAndName extends StatefulWidget {
  final ImageAndName? imageAndName;
  final PreferredSizeWidget? appBar;
  final int? maxLines, minLines;
  final bool allowEmpty;
  final String? hintText;
  final String? selectPictureLabel;
  const EditImageAndName({
    Key? key,
    this.imageAndName,
    this.appBar,
    this.maxLines,
    this.minLines,
    this.allowEmpty = false,
    this.hintText,
    this.selectPictureLabel,
  }) : super(key: key);

  @override
  State createState() => _EditImageAndNameState();
}

class _EditImageAndNameState extends State<EditImageAndName> {
  late ImageAndName _imageAndName;
  late TextEditingController _textEditController;

  @override
  void initState() {
    super.initState();
    _imageAndName = widget.imageAndName ?? ImageAndName.empty;
    _textEditController = SpokenTextEditController.ifApplicable(context,
        text: _imageAndName.name);
  }

  @override
  Widget build(BuildContext context) {
    final appbar = widget.appBar;
    final heading = Translator.of(context).translate.name;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (appbar != null)
          SizedBox(
            height: appbar.preferredSize.height,
            child: appbar,
          ),
        Container(
          color: AbiliaColors.white110,
          child: Padding(
            padding: layout.templates.m1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SelectPictureWidget(
                  selectedImage: _imageAndName.image,
                  label: widget.selectPictureLabel,
                  onImageSelected: (selectedImage) => setState(
                    () => _imageAndName =
                        _imageAndName.copyWith(image: selectedImage),
                  ),
                ),
                SizedBox(width: layout.formPadding.groupHorizontalDistance),
                Expanded(
                  child: Tts.fromSemantics(
                    SemanticsProperties(label: heading),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SubHeading(heading),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textEditController,
                                decoration:
                                    InputDecoration(hintText: widget.hintText),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: Theme.of(context).textTheme.bodyText1,
                                autofocus: true,
                                onEditingComplete:
                                    Navigator.of(context).maybePop,
                                onChanged: (text) => setState(() =>
                                    _imageAndName =
                                        _imageAndName.copyWith(name: text)),
                                maxLines: widget.maxLines,
                                minLines: widget.minLines,
                              ),
                            ),
                            TtsPlayButton(
                              controller: _textEditController,
                              padding: EdgeInsets.only(
                                left: layout
                                    .formPadding.largeHorizontalItemDistance,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        BottomNavigation(
          useVerticalSafeArea: false,
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            key: TestKey.bottomSheetOKButton,
            onPressed: !widget.allowEmpty && _imageAndName.isEmpty
                ? null
                : () => Navigator.of(context).pop(_imageAndName),
          ),
        ),
      ],
    ).pad(EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom));
  }
}
