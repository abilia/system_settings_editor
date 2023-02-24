extension NullOnEmpty on String {
  String? nullOnEmpty() => isNotEmpty ? this : null;
}
