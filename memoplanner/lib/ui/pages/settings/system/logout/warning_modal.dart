part of 'logout_page.dart';

class _WarningModal extends StatelessWidget {
  const _WarningModal({
    required this.onLogoutPressed,
    Key? key,
  }) : super(key: key);
  final Function(BuildContext context) onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogoutSyncCubit>(
      create: (context) => LogoutSyncCubit(
        syncBloc: context.read<SyncBloc>(),
        connectivity: Connectivity().onConnectivityChanged,
      ),
      child: BlocBuilder<LogoutSyncCubit, LogoutSyncState>(
        builder: (context, state) {
          final body = _body(
            state.warningSyncState,
            state.warningStep,
            state.dirtyItems,
          );

          return _LogoutModal(
            icon: _icon(state.warningSyncState, state.warningStep),
            title: _title(
              context,
              state.warningSyncState,
              state.warningStep,
            ),
            label: _label(
              context,
              state.warningSyncState,
              context.read<SyncBloc>().state.lastSynced,
            ),
            onLogoutPressed: _onLogoutPressed(
              context,
              state.warningSyncState,
              state.warningStep,
            ),
            body: body,
            bodyWithoutBottomPadding: layout.go && body is _SecondWarningBody,
          );
        },
      ),
    );
  }

  Function(BuildContext context)? _onLogoutPressed(
    BuildContext context,
    WarningSyncState warningSyncState,
    WarningStep warningStep,
  ) {
    switch (warningSyncState) {
      case WarningSyncState.syncing:
        return null;
      case WarningSyncState.syncedSuccess:
        return onLogoutPressed;
      case WarningSyncState.syncFailed:
        if (warningStep == WarningStep.secondWarning) {
          return onLogoutPressed;
        }
        return (_) {
          context
              .read<LogoutSyncCubit>()
              .setWarningStep(WarningStep.secondWarning);
        };
    }
  }

  Widget? _body(
    WarningSyncState warningSyncState,
    WarningStep warningStep,
    DirtyItems? dirtyItems,
  ) {
    if (warningStep == WarningStep.firstWarning &&
        warningSyncState != WarningSyncState.syncedSuccess) {
      return const _InternetConnection();
    } else if (warningStep == WarningStep.secondWarning) {
      return dirtyItems == null
          ? const AbiliaProgressIndicator()
          : _SecondWarningBody(
              warningState: warningSyncState,
              dirtyItems: dirtyItems,
            );
    }
    return null;
  }

  Widget _icon(WarningSyncState warningSyncState, WarningStep warningStep) {
    switch (warningSyncState) {
      case WarningSyncState.syncing:
        final sideLength = layout.logout.modalIconSize -
            layout.logout.modalProgressIndicatorStrokeWidth;
        return Padding(
          padding: EdgeInsets.all(
            layout.logout.modalProgressIndicatorStrokeWidth / 2,
          ),
          child: SizedBox(
            width: sideLength,
            height: sideLength,
            child: AbiliaProgressIndicator(
              strokeWidth: layout.logout.modalProgressIndicatorStrokeWidth,
            ),
          ),
        );
      case WarningSyncState.syncedSuccess:
        return Icon(
          AbiliaIcons.ok,
          color: AbiliaColors.green,
          size: layout.logout.modalIconSize,
        );
      case WarningSyncState.syncFailed:
        return Icon(
          warningStep == WarningStep.firstWarning
              ? AbiliaIcons.noWifi
              : AbiliaIcons.irError,
          color: AbiliaColors.red,
          size: layout.logout.modalIconSize,
        );
    }
  }

  String? _label(
    BuildContext context,
    WarningSyncState warningSyncState,
    DateTime? lastSync,
  ) {
    final t = Translator.of(context).translate;
    switch (warningSyncState) {
      case WarningSyncState.syncing:
        return t.syncing;
      case WarningSyncState.syncedSuccess:
        return t.canLogOutSafely;
      case WarningSyncState.syncFailed:
        if (lastSync == null) {
          return null;
        }
        final daysAgo = context
            .read<ClockBloc>()
            .state
            .onlyDays()
            .difference(lastSync.onlyDays())
            .inDays;

        final daysAgoString = daysAgo == 1 ? t.oneDayAgo : t.manyDaysAgo;
        final dateString = DateFormat('d/M/y').format(lastSync.onlyDays());
        return '${t.lastSyncWas} $dateString ($daysAgo $daysAgoString).';
    }
  }

  String _title(
    BuildContext context,
    WarningSyncState syncState,
    WarningStep warningState,
  ) {
    final t = Translator.of(context).translate;
    switch (syncState) {
      case WarningSyncState.syncedSuccess:
        return t.allDataSaved;
      case WarningSyncState.syncing:
      case WarningSyncState.syncFailed:
        if (warningState == WarningStep.firstWarning) {
          return t.goOnlineBeforeLogout;
        }
        return t.doNotLoseYourContent;
    }
  }
}

class _InternetConnection extends StatelessWidget {
  const _InternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return layout.go
        ? InfoRow(
            state: InfoRowState.normal,
            icon: AbiliaIcons.noWifi,
            title: t.connectToInternetToLogOut,
            padding: layout.logout.noInternetGOPadding,
            textColor: AbiliaColors.black75,
          )
        : const WiFiPickField();
  }
}

class _SecondWarningBody extends StatefulWidget {
  const _SecondWarningBody({
    required this.dirtyItems,
    required this.warningState,
    Key? key,
  }) : super(key: key);

  final DirtyItems dirtyItems;
  final WarningSyncState warningState;

  @override
  State<_SecondWarningBody> createState() => _SecondWarningBodyState();
}

class _SecondWarningBodyState extends State<_SecondWarningBody> {
  late final DirtyItems _dirtyStart;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dirtyStart = widget.dirtyItems;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final labelStyle = Theme.of(context)
        .textTheme
        .bodyText2
        ?.copyWith(color: AbiliaColors.black75);

    late final InfoRowState defaultInfoRowState;
    if (widget.warningState == WarningSyncState.syncFailed) {
      defaultInfoRowState = InfoRowState.critical;
    } else if (widget.warningState == WarningSyncState.syncing) {
      defaultInfoRowState = InfoRowState.criticalLoading;
    } else {
      defaultInfoRowState = InfoRowState.verified;
    }

    final infoItems = [
      if (_dirtyStart.activities > 0)
        InfoRow(
          state: widget.dirtyItems.activities == 0
              ? InfoRowState.verified
              : defaultInfoRowState,
          icon: AbiliaIcons.day,
          title:
              '${_dirtyStart.activities} ${(_dirtyStart.activities == 1 ? t.activity : t.activities).toLowerCase()}',
        ),
      if (_dirtyStart.activityTemplates > 0)
        InfoRow(
          state: widget.dirtyItems.activityTemplates == 0
              ? InfoRowState.verified
              : defaultInfoRowState,
          icon: AbiliaIcons.basicActivities,
          title:
              '${_dirtyStart.activityTemplates} ${(_dirtyStart.activityTemplates == 1 ? t.activityTemplateSingular : t.activityTemplatePlural)}',
        ),
      if (_dirtyStart.photos > 0)
        InfoRow(
          state: widget.dirtyItems.photos == 0
              ? InfoRowState.verified
              : defaultInfoRowState,
          icon: AbiliaIcons.myPhotos,
          title:
              '${_dirtyStart.photos} ${(_dirtyStart.photos == 1 ? t.photoSingular : t.photoPlural)}',
        ),
      if (_dirtyStart.timerTemplate > 0)
        InfoRow(
          state: widget.dirtyItems.timerTemplate == 0
              ? InfoRowState.verified
              : defaultInfoRowState,
          icon: AbiliaIcons.basicTimers,
          title:
              '${_dirtyStart.timerTemplate} ${(_dirtyStart.timerTemplate == 1 ? t.timerTemplateSingular : t.timerTemplatePlural)}',
        ),
      if (_dirtyStart.settingsData)
        InfoRow(
          state: !widget.dirtyItems.settingsData
              ? InfoRowState.verified
              : defaultInfoRowState,
          icon: AbiliaIcons.settings,
          title: t.settingsData,
        ),
    ];

    final List<Widget> infoItemsLeftColumn = [];
    final List<Widget> infoItemsRightColumn = [];

    for (int i = 0; i < infoItems.length; i++) {
      if (i.isEven) {
        infoItemsLeftColumn.add(infoItems[i]);
      } else {
        infoItemsRightColumn.add(infoItems[i]);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.warningState != WarningSyncState.syncedSuccess) ...[
          Tts(
            child: Text(
              t.connectToWifiToLogOut,
              style: labelStyle,
            ),
          ),
          const _InternetConnection(),
          SizedBox(
            height: layout.logout.modalBodyTopSpacing,
          ),
          Tts(
            child: Text(
              t.ifYouLogoutYouWillLose,
              style: labelStyle,
            ),
          ),
        ],
        if (layout.go || infoItems.length == 1)
          Flexible(
            child: ScrollArrows.vertical(
              controller: scrollController,
              child: ListView.separated(
                shrinkWrap: true,
                controller: scrollController,
                itemBuilder: (_, int index) {
                  return infoItems[index];
                },
                separatorBuilder: (_, __) {
                  return SizedBox(
                      height: layout.logout.infoItemVerticalSpacing);
                },
                itemCount: infoItems.length,
              ),
            ).pad(layout.logout.infoItemsCollectionPadding),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: infoItemsLeftColumn,
                ).spacing(layout.logout.infoItemVerticalSpacing),
              ),
              SizedBox(width: layout.logout.infoItemHorizontalSpacing),
              Expanded(
                child: Column(
                  children: infoItemsRightColumn,
                ).spacing(layout.logout.infoItemVerticalSpacing),
              ),
            ],
          ).pad(layout.logout.infoItemsCollectionPadding),
      ],
    );
  }
}

class _LogoutModal extends StatelessWidget {
  const _LogoutModal({
    required this.icon,
    required this.title,
    required this.body,
    required this.onLogoutPressed,
    this.label,
    this.bodyWithoutBottomPadding = false,
  });

  final Widget icon;
  final Widget? body;
  final String title;
  final String? label;
  final bool bodyWithoutBottomPadding;
  final Function(BuildContext context)? onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    final labelString = label;
    final onLogout = onLogoutPressed;
    final bodyWidget = body;

    return SafeArea(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AbiliaColors.white110,
            borderRadius:
                BorderRadius.circular(layout.logout.modalBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Padding(
                  padding: bodyWithoutBottomPadding
                      ? layout.templates.l2.withoutBottom
                      : layout.templates.l2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      SizedBox(
                        height: layout.logout.modalIconBottomSpacing,
                      ),
                      Tts(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      SizedBox(
                        height: layout.logout.modalTitleBottomSpacing,
                      ),
                      if (labelString != null)
                        Tts(
                          child: Text(
                            labelString,
                            style:
                                Theme.of(context).textTheme.subtitle2?.copyWith(
                                      color: AbiliaColors.black75,
                                    ),
                          ),
                        ),
                      SizedBox(
                        height: layout.logout.modalBodyTopSpacing,
                      ),
                      if (bodyWidget != null) Flexible(child: bodyWidget),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CloseButton(
                      style: iconTextButtonStyleGray.withoutMinWidth,
                    ),
                  ),
                  SizedBox(width: layout.logout.modalBottomRowSpacing),
                  Expanded(
                    child: LogoutButton(
                      style: iconTextButtonStyleRed.withoutMinWidth,
                      onPressed:
                          onLogout != null ? () => onLogout(context) : null,
                    ),
                  ),
                ],
              ).pad(layout.logout.modalBottomRowPadding),
            ],
          ),
        ),
      ),
    );
  }
}
