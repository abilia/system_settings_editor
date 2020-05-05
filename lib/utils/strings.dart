extension RemoveLeading on String {
  String removeLeadingZeros() => this.replaceFirst(RegExp('^0+(?!\$)'), '');
}
