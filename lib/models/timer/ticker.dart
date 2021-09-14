class AudioTicker {
  final int millisTickRate;
  const AudioTicker(this.millisTickRate);

  Stream<int> tick({required int duration}) {
    return Stream.periodic(
            Duration(milliseconds: millisTickRate), (x) => x * millisTickRate)
        .take(duration ~/ millisTickRate);
  }
}
