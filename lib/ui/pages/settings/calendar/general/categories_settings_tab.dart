import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CategoriesSettingsTab extends StatelessWidget {
  const CategoriesSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralCalendarSettingsCubit,
        GeneralCalendarSettingsState>(
      builder: (context, state) {
        final t = Translator.of(context).translate;
        return SettingsTab(
          children: [
            _CategoriesPreview(state: state),
            const SizedBox.shrink(),
            SwitchField(
              value: state.categories.show,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeCategorySettings(
                    state.categories.copyWith(show: value),
                  ),
              leading: const Icon(AbiliaIcons.categories),
              child: Text(t.showCagetories),
            ),
            CollapsableWidget(
              collapsed: !state.categories.show,
              child: Column(
                children: [
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  _CategoryPickField(
                    key: TestKey.editLeftCategory,
                    imageAndName: state.categories.left,
                    defaultName: t.left,
                    onResult: (r) => state.categories.copyWith(left: r),
                  ),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  _CategoryPickField(
                    key: TestKey.editRigthCategory,
                    imageAndName: state.categories.right,
                    defaultName: t.right,
                    onResult: (r) => state.categories.copyWith(right: r),
                  ),
                  SizedBox(height: layout.formPadding.groupBottomDistance),
                  SwitchField(
                    value: state.categories.colors,
                    onChanged: (value) => context
                        .read<GeneralCalendarSettingsCubit>()
                        .changeCategorySettings(
                          state.categories.copyWith(colors: value),
                        ),
                    leading: const Icon(AbiliaIcons.changePageColor),
                    child: Text(t.showColours),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryPickField extends StatelessWidget {
  final ImageAndName imageAndName;
  final String defaultName;
  final CategoriesSettingState Function(ImageAndName) onResult;

  const _CategoryPickField({
    required this.imageAndName,
    required this.defaultName,
    required this.onResult,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leadingPadding = imageAndName.hasImage
        ? layout.category.settingsRadioImagePadding
        : null;
    final padding = imageAndName.hasImage
        ? EdgeInsets.only(right: layout.pickField.padding.right)
        : null;
    return PickField(
      text: Text(imageAndName.hasName ? imageAndName.name : defaultName),
      leadingPadding: leadingPadding,
      padding: padding,
      leading: imageAndName.image.isNotEmpty
          ? AspectRatio(
              aspectRatio: 1,
              child: FadeInAbiliaImage(
                imageFileId: imageAndName.image.id,
                imageFilePath: imageAndName.image.path,
              ),
            )
          : null,
      onTap: () async {
        final generalCalendarSettingsCubit =
            context.read<GeneralCalendarSettingsCubit>();
        final result = await showAbiliaBottomSheet<ImageAndName>(
          context: context,
          providers: copiedAuthProviders(context),
          child: EditCategoryBottomSheet(
            imageAndName: imageAndName,
            hintText: defaultName,
          ),
        );
        if (result != null) {
          generalCalendarSettingsCubit.changeCategorySettings(onResult(result));
        }
      },
    );
  }
}

class _CategoriesPreview extends StatelessWidget {
  const _CategoriesPreview({
    required this.state,
    Key? key,
  }) : super(key: key);
  final GeneralCalendarSettingsState state;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          vertical: layout.formPadding.verticalItemDistance,
        ),
        decoration: whiteBoxDecoration,
        child: BlocProvider(
          create: (context) => ClockBloc.fixed(DateTime(2021, 1, 1, 8, 30)),
          child: BlocBuilder<TimepillarMeasuresCubit, TimepillarMeasures>(
            builder: (context, measures) => LayoutBuilder(
              builder: (context, boxConstraints) {
                final categoryWidth =
                    (boxConstraints.maxWidth - measures.timePillarTotalWidth) /
                        2;
                return Stack(
                  children: [
                    if (state.categories.show)
                      CategoryLeft(
                        categoryName: state.categories.left.name,
                        fileId: state.categories.left.image.id,
                        maxWidth: categoryWidth,
                        showColors: state.categories.colors,
                      ),
                    Align(
                      alignment: state.categories.show
                          ? Alignment.center
                          : Alignment.topLeft,
                      child: TimePillar(
                        preview: true,
                        dayOccasion: Occasion.current,
                        dayParts: DayParts.standard(),
                        use12h: state.timepillar.use12h,
                        nightParts: const [],
                        interval: TimepillarInterval(
                          start: DateTime(2021, 1, 1, 7),
                          end: DateTime(2021, 1, 1, 10),
                        ),
                        columnOfDots: state.timepillar.columnOfDots,
                        topMargin: 0.0,
                        measures: measures,
                      ),
                    ),
                    if (state.categories.show)
                      CategoryRight(
                        categoryName: state.categories.right.name,
                        fileId: state.categories.right.image.id,
                        maxWidth: categoryWidth,
                        showColors: state.categories.colors,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}
