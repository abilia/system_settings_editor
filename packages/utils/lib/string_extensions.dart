extension NullOnEmpty on String {
  String? nullOnEmpty() => isNotEmpty ? this : null;
}

extension UriExtension on String {
  Uri toUri() {
    return Uri.parse(this);
  }
}
