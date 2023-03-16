
class RecordingLayout {
  final double trackHeight, thumbRadius;

  const RecordingLayout({
    this.trackHeight = 4,
    this.thumbRadius = 12,
  });
}

class RecordingLayoutMedium extends RecordingLayout {
  const RecordingLayoutMedium()
      : super(
          trackHeight: 6,
          thumbRadius: 18,
        );
}
