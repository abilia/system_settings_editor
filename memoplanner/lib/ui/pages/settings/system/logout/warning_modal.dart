part of 'logout_page.dart';

enum _WarningVariants {
  firstWarningOffline,
  firstWarningSyncing,
  firstWarningSuccess,
  secondWarningOffline,
  secondWarningSyncing,
  secondWarningSuccess,
  licenseExpiredWarning;

  WarningStep get step {
    switch (this) {
      case _WarningVariants.firstWarningOffline:
      case _WarningVariants.firstWarningSyncing:
      case _WarningVariants.firstWarningSuccess:
        return WarningStep.firstWarning;
      case _WarningVariants.secondWarningOffline:
      case _WarningVariants.secondWarningSyncing:
      case _WarningVariants.secondWarningSuccess:
        return WarningStep.secondWarning;
      case _WarningVariants.licenseExpiredWarning:
        return WarningStep.licenseExpiredWarning;
    }
  }

  WarningSyncState get syncState {
    switch (this) {
      case _WarningVariants.firstWarningOffline:
      case _WarningVariants.secondWarningOffline:
      case _WarningVariants.licenseExpiredWarning:
        return WarningSyncState.syncFailed;
      case _WarningVariants.firstWarningSyncing:
      case _WarningVariants.secondWarningSyncing:
        return WarningSyncState.syncing;
      case _WarningVariants.firstWarningSuccess:
      case _WarningVariants.secondWarningSuccess:
        return WarningSyncState.syncedSuccess;
    }
  }
}

_WarningVariants _getWarningVariant({
  required bool online,
  required bool validLicense,
  required WarningStep step,
  required WarningSyncState syncState,
}) {
  if (online && !validLicense) {
    return _WarningVariants.licenseExpiredWarning;
  }
  switch (step) {
    case WarningStep.firstWarning:
      switch (syncState) {
        case WarningSyncState.syncing:
          return _WarningVariants.firstWarningSyncing;
        case WarningSyncState.syncedSuccess:
          return _WarningVariants.firstWarningSuccess;
        case WarningSyncState.syncFailed:
          return _WarningVariants.firstWarningOffline;
      }
    case WarningStep.secondWarning:
    case WarningStep.licenseExpiredWarning:
      if (!validLicense &&
          syncState != WarningSyncState.syncedSuccess &&
          step == WarningStep.licenseExpiredWarning) {
        return _WarningVariants.licenseExpiredWarning;
      }
      switch (syncState) {
        case WarningSyncState.syncing:
          return _WarningVariants.secondWarningSyncing;
        case WarningSyncState.syncedSuccess:
          return _WarningVariants.secondWarningSuccess;
        case WarningSyncState.syncFailed:
          return _WarningVariants.secondWarningOffline;
      }
  }
}

@visibleForTesting
class WarningModal extends StatelessWidget {
  const WarningModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LogoutSyncCubit>().state;
    final validLicense = context.select((LicenseCubit c) => c.validLicense);

    final warningVariant = _getWarningVariant(
      online: state.isOnline ?? false,
      validLicense: validLicense,
      step: state.warningStep,
      syncState: state.warningSyncState,
    );

    return _LogoutModal(
      key: TestKey.logoutModal,
      icon: _icon(warningVariant),
      title: _title(
        context,
        warningVariant,
      ),
      label: _label(
        context,
        warningVariant,
        context.read<SyncBloc>().state.lastSynced,
      ),
      onLogoutPressed: _onLogoutPressed(warningVariant),
      body: _Body(
        dirtyItems: state.dirtyItems,
        variant: warningVariant,
      ),
      bodyWithoutBottomPadding:
          layout.go && warningVariant.step != WarningStep.firstWarning,
    );
  }

  Function(BuildContext context)? _onLogoutPressed(_WarningVariants variant) {
    switch (variant) {
      case _WarningVariants.firstWarningOffline:
        return (context) {
          context
              .read<LogoutSyncCubit>()
              .setWarningStep(WarningStep.secondWarning);
        };
      case _WarningVariants.secondWarningOffline:
        return (context) => context.read<LicenseCubit>().validLicense
            ? context.read<AuthenticationBloc>().add(const LoggedOut())
            : context
                .read<LogoutSyncCubit>()
                .setWarningStep(WarningStep.licenseExpiredWarning);
      case _WarningVariants.firstWarningSyncing:
      case _WarningVariants.secondWarningSyncing:
        return null;
      case _WarningVariants.firstWarningSuccess:
      case _WarningVariants.secondWarningSuccess:
      case _WarningVariants.licenseExpiredWarning:
        return (context) =>
            context.read<AuthenticationBloc>().add(const LoggedOut());
    }
  }

  Widget _icon(_WarningVariants variant) {
    switch (variant) {
      case _WarningVariants.firstWarningSyncing:
      case _WarningVariants.secondWarningSyncing:
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
              key: TestKey.logoutModalProgressIndicator,
              strokeWidth: layout.logout.modalProgressIndicatorStrokeWidth,
            ),
          ),
        );

      case _WarningVariants.firstWarningSuccess:
      case _WarningVariants.secondWarningSuccess:
        return Icon(
          AbiliaIcons.ok,
          key: TestKey.logoutModalOkIcon,
          color: AbiliaColors.green,
          size: layout.logout.modalIconSize,
        );
      case _WarningVariants.firstWarningOffline:
        return Icon(
          AbiliaIcons.noWifi,
          color: AbiliaColors.red,
          size: layout.logout.modalIconSize,
        );
      case _WarningVariants.secondWarningOffline:
      case _WarningVariants.licenseExpiredWarning:
        return Icon(
          AbiliaIcons.irError,
          color: AbiliaColors.red,
          size: layout.logout.modalIconSize,
        );
    }
  }

  String? _label(
    BuildContext context,
    _WarningVariants variant,
    DateTime? lastSync,
  ) {
    final t = Translator.of(context).translate;

    switch (variant) {
      case _WarningVariants.firstWarningSyncing:
      case _WarningVariants.secondWarningSyncing:
        return t.syncing;
      case _WarningVariants.firstWarningSuccess:
      case _WarningVariants.secondWarningSuccess:
        return t.canLogOutSafely;
      case _WarningVariants.firstWarningOffline:
      case _WarningVariants.secondWarningOffline:
        if (lastSync == null) {
          return null;
        }
        final daysAgo = context.read<ClockBloc>().state.difference(lastSync);
        final locale = Localizations.localeOf(context);

        final dateString =
            DateFormat.yMd(locale.languageCode).format(lastSync.onlyDays());
        return '${t.lastSyncWas} $dateString (${daysAgo.comparedToNowString(t, false, daysOnly: true)}).';
      case _WarningVariants.licenseExpiredWarning:
        return t.needLicenseToSaveData;
    }
  }

  String _title(
    BuildContext context,
    _WarningVariants variant,
  ) {
    final t = Translator.of(context).translate;
    switch (variant) {
      case _WarningVariants.firstWarningSuccess:
      case _WarningVariants.secondWarningSuccess:
        return t.allDataSaved;
      case _WarningVariants.firstWarningOffline:
      case _WarningVariants.firstWarningSyncing:
        return t.goOnlineBeforeLogout;
      case _WarningVariants.secondWarningOffline:
      case _WarningVariants.secondWarningSyncing:
        return t.doNotLoseYourContent;
      case _WarningVariants.licenseExpiredWarning:
        return t.memoplannerLicenseExpired;
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
            padding: layout.logout.infoPadding,
            textColor: AbiliaColors.black75,
          )
        : const WiFiPickField();
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.variant,
    required this.dirtyItems,
    Key? key,
  }) : super(key: key);

  final DirtyItems? dirtyItems;
  final _WarningVariants variant;

  @override
  Widget build(BuildContext context) {
    final dirty = dirtyItems;
    final t = Translator.of(context).translate;
    final labelStyle = Theme.of(context)
        .textTheme
        .bodyText2
        ?.copyWith(color: AbiliaColors.black75);

    switch (variant) {
      case _WarningVariants.firstWarningSuccess:
        return const SizedBox.shrink();

      case _WarningVariants.firstWarningOffline:
        return const _InternetConnection();
      case _WarningVariants.firstWarningSyncing:
        return layout.go
            ? const SizedBox.shrink()
            : const _InternetConnection();

      case _WarningVariants.secondWarningOffline:
      case _WarningVariants.secondWarningSyncing:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (variant == _WarningVariants.secondWarningOffline && layout.go ||
                !layout.go) ...[
              if (!layout.go)
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
            ],
            if (dirty == null)
              const AbiliaProgressIndicator()
            else
              Flexible(
                child: _DirtyItems(
                  dirtyItems: dirty,
                  variant: variant,
                ),
              ),
          ],
        );

      case _WarningVariants.secondWarningSuccess:
        return dirty == null
            ? const AbiliaProgressIndicator()
            : _DirtyItems(
                dirtyItems: dirty,
                variant: variant,
              );

      case _WarningVariants.licenseExpiredWarning:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoRow(
              state: InfoRowState.normal,
              icon: AbiliaIcons.supportCall,
              title: t.contactProviderToExtendLicense,
              padding: layout.logout.infoPadding,
              textColor: AbiliaColors.black75,
            ),
            SizedBox(
              height: layout.logout.modalBodyTopSpacing,
            ),
            if (dirty == null)
              const AbiliaProgressIndicator()
            else
              Flexible(
                child: _DirtyItems(
                  dirtyItems: dirty,
                  variant: variant,
                ),
              ),
          ],
        );
    }
  }
}

class _DirtyItems extends StatefulWidget {
  const _DirtyItems({
    required this.dirtyItems,
    required this.variant,
    Key? key = TestKey.dirtyItems,
  }) : super(key: key);

  final DirtyItems dirtyItems;
  final _WarningVariants variant;

  @override
  State<_DirtyItems> createState() => _DirtyItemsState();
}

class _DirtyItemsState extends State<_DirtyItems> {
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
    if (widget.variant.syncState == WarningSyncState.syncFailed) {
      defaultInfoRowState = InfoRowState.critical;
    } else if (widget.variant.syncState == WarningSyncState.syncing) {
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
        if (widget.variant.step != WarningStep.firstWarning &&
            widget.variant.syncState != WarningSyncState.syncedSuccess)
          Tts(
            child: Text(
              t.ifYouLogoutYouWillLose,
              style: labelStyle,
            ),
          ),
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
    Key? key,
  }) : super(key: key);

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
