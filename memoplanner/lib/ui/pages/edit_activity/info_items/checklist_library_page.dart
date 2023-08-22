import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ChecklistLibraryPage extends StatelessWidget {
  const ChecklistLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocProvider<SortableArchiveCubit<ChecklistData>>(
        create: (_) => SortableArchiveCubit<ChecklistData>(
          sortableBloc: BlocProvider.of<SortableBloc>(context),
        ),
        child: LibraryPage<ChecklistData>.selectable(
          useHeading: false,
          appBar: _ChecklistLibraryAppBar(),
          libraryItemGenerator: (checklist) =>
              LibraryChecklist(checklist: checklist.data.checklist),
          selectedItemGenerator: (checklist) =>
              FullScreenChecklist(checklist: checklist.data.checklist),
          emptyLibraryMessage: Lt.of(context).noChecklists,
          onOk: (selected) =>
              Navigator.of(context).pop<Checklist>(selected.data.checklist),
        ),
      );
}

class LibraryChecklist extends StatelessWidget {
  final Checklist checklist;

  const LibraryChecklist({
    required this.checklist,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageId = checklist.fileId;
    final name = checklist.name;
    final iconPath = checklist.image;
    return LibraryImage(
      name: name,
      isImage: imageId.isNotEmpty || checklist.hasImage,
      imageId: imageId,
      iconPath: iconPath,
    );
  }
}

class FullScreenChecklist extends StatelessWidget {
  const FullScreenChecklist({
    required this.checklist,
    Key? key,
  }) : super(key: key);
  final Checklist checklist;

  @override
  Widget build(BuildContext context) => Container(
        margin: layout.templates.m3,
        decoration: whiteBoxDecoration,
        child: ChecklistView(checklist, padding: layout.templates.s2),
      );
}

class _ChecklistLibraryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final sortableState =
        context.watch<SortableArchiveCubit<ChecklistData>>().state;

    return AbiliaAppBar(
      iconData: AbiliaIcons.documents,
      title: Lt.of(context).fromTemplate,
      breadcrumbs: sortableState.selected != null
          ? [sortableState.selected!.data.checklist.name]
          : sortableState.breadCrumbPath(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(layout.appBar.smallHeight);
}
