import 'package:auth/auth.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:repository_base/db.dart';
import 'package:repository_base/end_point.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:user_files/user_files.dart';

class AbiliaImage extends StatelessWidget {
  const AbiliaImage(
    this.imageFile, {
    super.key,
    this.size = ImageSize.original,
  });
  final AbiliaFile imageFile;
  final ImageSize size;

  @override
  Widget build(BuildContext context) {
    final file = context.select(
      (UserFileBloc bloc) => bloc.state.getLoadedByIdOrPath(
        imageFile.id,
        imageFile.path,
        GetIt.I<FileStorage>(),
        imageSize: size,
      ),
    );
    if (file != null) return Image.file(file);
    final authenticatedState = context.watch<AuthenticationBloc>().state;
    if (authenticatedState is Authenticated) {
      return Image.network(
        imageThumbUrl(
          baseUrl: GetIt.I<BaseUrlDb>().baseUrl,
          userId: authenticatedState.userId,
          imageFileId: imageFile.id,
          imagePath: imageFile.path,
        ),
        errorBuilder: (context, error, stackTrace) =>
            Image.memory(kTransparentImage),
        headers: authHeader(GetIt.I<LoginDb>().getToken()),
      );
    }
    return Image.memory(kTransparentImage);
  }
}
