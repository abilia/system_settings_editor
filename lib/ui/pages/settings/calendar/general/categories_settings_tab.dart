import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CategoriesSettingsTab extends StatelessWidget {
  const CategoriesSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralCalendarSettingsCubit,
        GeneralCalendarSettingsState>(
      builder: (context, state) {
        final cState = state.categories;
        final t = Translator.of(context).translate;
        return SettingsTab(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.s),
                decoration: boxDecoration,
                child: Stack(
                  children: [
                    if (cState.showCategories)
                      IgnorePointer(
                        child: CategoryLeft(
                          expanded: true,
                          categoryName: cState.leftCategoryName,
                        ),
                      ),
                    const TimepillarExample(),
                    if (cState.showCategories)
                      IgnorePointer(
                        child: CategoryRight(
                          expanded: true,
                          categoryName: cState.rigthCategoryName,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox.shrink(),
            SwitchField(
              value: cState.showCategories,
              onChanged: (value) => context
                  .read<GeneralCalendarSettingsCubit>()
                  .changeCategorySettings(
                    cState.copyWith(showCategories: value),
                  ),
              text: Text(t.showCagetories),
            ),
            CollapsableWidget(
              collapsed: !cState.showCategories,
              child: Column(
                children: [
                  SizedBox(height: 8.s),
                  PickField(
                    text: Text(cState.leftCategoryName ?? t.left),
                  ),
                  SizedBox(height: 8.s),
                  PickField(text: Text(cState.rigthCategoryName ?? t.right)),
                  SizedBox(height: 16.s),
                  SwitchField(
                    value: cState.showColors,
                    onChanged: (value) => context
                        .read<GeneralCalendarSettingsCubit>()
                        .changeCategorySettings(
                          cState.copyWith(showColors: value),
                        ),
                    text: Text(Translator.of(context).translate.showColours),
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

class TimepillarExample extends StatelessWidget {
  const TimepillarExample({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClockBloc(
        StreamController<DateTime>().stream,
        initialTime: DateTime(2021, 1, 1, 8, 30),
      ),
      child: BlocBuilder<GeneralCalendarSettingsCubit,
          GeneralCalendarSettingsState>(
        buildWhen: (previous, current) =>
            previous.timepillar != current.timepillar,
        builder: (context, state) {
          return Center(
            child: TimePillar(
              preview: true,
              dayOccasion: Occasion.current,
              dayParts: DayParts.standard(),
              use12h: state.timepillar.use12h,
              nightParts: [],
              interval: TimepillarInterval(
                start: DateTime(2021, 1, 1, 7),
                end: DateTime(2021, 1, 1, 10),
              ),
              showTimeLine: false,
              columnOfDots: state.timepillar.columnOfDots,
            ),
          );
        },
      ),
    );
  }
}
