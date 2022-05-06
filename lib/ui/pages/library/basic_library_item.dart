import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicLibraryItem<T extends SortableData> extends StatelessWidget {
  final Sortable<T> sortable;

  const BasicLibraryItem({
    Key? key,
    required this.sortable,
  }) : super(key: key);

  static final imageHeight = layout.libraryPage.imageHeight,
      imageWidth = layout.libraryPage.imageWidth;

  @override
  Widget build(BuildContext context) {
    final basicLibraryData = sortable.data;
    final imageId = basicLibraryData.dataFileId();
    final name = basicLibraryData.title(Translator.of(context).translate);
    final iconPath = basicLibraryData.dataFilePath();

    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (innerContext, state) {
        final selected = state.selected;
        final isSelected = selected == sortable;
        return Tts.fromSemantics(
          SemanticsProperties(label: name),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => context
                  .read<SortableArchiveCubit<T>>()
                  .sortableSelected(sortable),
              borderRadius: borderRadius,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(microseconds: 400),
                    decoration:
                        isSelected ? selectedBoxDecoration : boxDecoration,
                    padding: layout.templates.s3.subtract(
                      isSelected
                          ? EdgeInsets.all(layout.borders.thin)
                          : EdgeInsets.zero,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (name.isNotEmpty)
                          Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: abiliaTextTheme.caption?.copyWith(height: 1),
                          ),
                        SizedBox(height: layout.libraryPage.textImageDistance),
                        SizedBox(
                          height: imageHeight,
                          child: basicLibraryData.hasImage()
                              ? FadeInAbiliaImage(
                                  height: imageHeight,
                                  width: imageWidth,
                                  imageFileId: imageId,
                                  imageFilePath: iconPath,
                                )
                              : Icon(
                                  AbiliaIcons.day,
                                  size: layout.icon.large,
                                  color: AbiliaColors.white140,
                                ),
                        ),
                      ],
                    ),
                  ),
                  PositionedRadio<Sortable<T>>(
                    value: sortable,
                    groupValue: state.selected,
                    onChanged: (v) {
                      if (v != null) {
                        context
                            .read<SortableArchiveCubit<T>>()
                            .sortableSelected(v);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
