import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';

void main() {
  UserFile userFileWith({
    String path = '',
    String? contentType,
  }) {
    return UserFile(
      contentType: contentType,
      deleted: false,
      fileSize: 1,
      id: 'id',
      md5: 'md5',
      path: path,
      sha1: 'sha1',
      fileLoaded: true,
    );
  }

  test('Test isImage', () {
    expect(userFileWith().isImage, false);
    expect(userFileWith(path: 'apa.jpg').isImage, true);
    expect(
        userFileWith(path: 'apa.jpg', contentType: 'image/png').isImage, true);
    expect(
        userFileWith(path: 'apa.jpg', contentType: 'application/octet-stream')
            .isImage,
        true);
    expect(
        userFileWith(path: 'apa.txt', contentType: 'application/octet-stream')
            .isImage,
        false);
    expect(
        userFileWith(path: 'apa.JPG', contentType: 'application/octet-stream')
            .isImage,
        true);
  });
}
