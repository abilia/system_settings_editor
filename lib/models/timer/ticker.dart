class AudioTicker {
  const AudioTicker();

  Stream<int> tick({required int duration}) {
    return Stream.periodic(Duration(milliseconds: 50), (x) => x * 50)
        .take(duration ~/ 50);
  }
}
