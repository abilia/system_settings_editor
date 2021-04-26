import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImageAndName {
  final String name;
  final SelectedImage image;
  const ImageAndName(this.name, this.image);

  static ImageAndName get empty =>
      const ImageAndName(null, SelectedImage.empty);

  ImageAndName copyWith({
    String name,
    SelectedImage image,
  }) =>
      ImageAndName(
        name ?? this.name,
        image ?? this.image,
      );

  bool get hasName => name?.isNotEmpty == true;
  bool get isEmpty => !hasName && image.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class EditImageAndName extends StatefulWidget {
  final ImageAndName imageAndName;
  final PreferredSizeWidget appBar;
  final int maxLines, minLines;
  final bool allowEmpty;
  final String hintText;
  const EditImageAndName({
    Key key,
    this.imageAndName,
    this.appBar,
    this.maxLines,
    this.minLines,
    this.allowEmpty = false,
    this.hintText,
  }) : super(key: key);

  @override
  _EditImageAndNameState createState() => imageAndName == null
      ? _EditImageAndNameState(ImageAndName.empty)
      : _EditImageAndNameState(imageAndName);
}

class _EditImageAndNameState extends State<EditImageAndName> {
  _EditImageAndNameState(this.imageAndName);
  ImageAndName imageAndName;
  TextEditingController txtEditController;
  bool get hasHint => widget.hintText?.isNotEmpty == true;
  @override
  void initState() {
    super.initState();
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
            padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0.0),
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
                          decoration: hasHint
                              ? InputDecoration(hintText: widget.hintText)
                              : null,
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
            backNavigationWidget: CancelButton(),
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
