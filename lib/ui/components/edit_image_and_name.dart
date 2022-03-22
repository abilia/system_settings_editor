import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditImageAndName extends StatefulWidget {
  final ImageAndName? imageAndName;
  final PreferredSizeWidget? appBar;
  final int? maxLines, minLines;
  final bool allowEmpty;
  final String? hintText;
  const EditImageAndName({
    Key? key,
    this.imageAndName,
    this.appBar,
    this.maxLines,
    this.minLines,
    this.allowEmpty = false,
    this.hintText,
  }) : super(key: key);

  @override
  _EditImageAndNameState createState() => _EditImageAndNameState();
}

class _EditImageAndNameState extends State<EditImageAndName> {
  late ImageAndName imageAndName;
  late TextEditingController txtEditController;

  @override
  void initState() {
    super.initState();
    imageAndName = widget.imageAndName ?? ImageAndName.empty;
    txtEditController = TextEditingController(text: imageAndName.name);
  }

  @override
  Widget build(BuildContext context) {
    final heading = Translator.of(context).translate.name;
    return Scaffold(
      appBar: widget.appBar,
      body: Column(
        children: <Widget>[
          Padding(
            padding: m1Padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SelectPictureWidget(
                  selectedImage: imageAndName.image,
                  onImageSelected: (selectedImage) => setState(
                    () => imageAndName =
                        imageAndName.copyWith(image: selectedImage),
                  ),
                ),
                SizedBox(width: 16.0.s),
                Expanded(
                  child: Tts.fromSemantics(
                    SemanticsProperties(label: heading),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SubHeading(heading),
                        TextField(
                          controller: txtEditController,
                          decoration:
                              InputDecoration(hintText: widget.hintText),
                          textCapitalization: TextCapitalization.sentences,
                          style: Theme.of(context).textTheme.bodyText1,
                          autofocus: true,
                          onEditingComplete: Navigator.of(context).maybePop,
                          onChanged: (text) => setState(() =>
                              imageAndName = imageAndName.copyWith(name: text)),
                          maxLines: widget.maxLines,
                          minLines: widget.minLines,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          BottomNavigation(
            useSafeArea: false,
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: OkButton(
              onPressed: !widget.allowEmpty && imageAndName.isEmpty
                  ? null
                  : () => Navigator.of(context).maybePop(imageAndName),
            ),
          ),
        ],
      ),
    );
  }
}
