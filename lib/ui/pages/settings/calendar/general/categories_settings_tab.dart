import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

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
              leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
              child: Text(t.showCagetories),
            ),
            CollapsableWidget(
              collapsed: !state.categories.show,
              child: Column(
                children: [
                  SizedBox(height: 8.s),
                  _CategoryPickField(
                    key: TestKey.editLeftCategory,
                    imageAndName: state.categories.left,
                    defaultName: t.left,
                    onResult: (r) => state.categories.copyWith(left: r),
                  ),
                  SizedBox(height: 8.s),
                  _CategoryPickField(
                    key: TestKey.editRigthCategory,
                    imageAndName: state.categories.right,
                    defaultName: t.right,
                    onResult: (r) => state.categories.copyWith(right: r),
                  ),
                  SizedBox(height: 16.s),
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
    Key? key,
    required this.imageAndName,
    required this.defaultName,
    required this.onResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PickField(
        text: Text(imageAndName.hasName ? imageAndName.name : defaultName),
        padding: imageAndName.image.isNotEmpty
            ? EdgeInsets.fromLTRB(4.s, 4.s, 12.s, 4.s)
            : null,
        leading: imageAndName.image.isNotEmpty
            ? FadeInAbiliaImage(
                imageFileId: imageAndName.image.id,
                imageFilePath: imageAndName.image.path,
                width: 48.s,
                height: 48.s,
              )
            : null,
        onTap: () async {
          final result = await Navigator.of(context).push<ImageAndName>(
            MaterialPageRoute(
              builder: (_) => CopiedAuthProviders(
                blocContext: context,
                child: EditCategoryPage(
                  imageAndName: imageAndName,
                  hintText: defaultName,
                ),
              ),
            ),
          );
          if (result != null) {
            context
                .read<GeneralCalendarSettingsCubit>()
                .changeCategorySettings(onResult(result));
          }
        },
      );
}

class _CategoriesPreview extends StatelessWidget {
  const _CategoriesPreview({
    Key? key,
    required this.state,
  }) : super(key: key);
  final GeneralCalendarSettingsState state;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: 8.s),
        decoration: boxDecoration,
        child: BlocProvider(
          create: (context) => ClockBloc(
            StreamController<DateTime>().stream,
            initialTime: DateTime(2021, 1, 1, 8, 30),
          ),
          child: BlocBuilder<TimepillarCubit, TimepillarState>(
            builder: (context, ts) => LayoutBuilder(
              builder: (context, boxConstraints) {
                final categoryWidth =
                    (boxConstraints.maxWidth - ts.timePillarTotalWidth) / 2;
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
                        timePillarState: ts,
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
