part of 'voices_cubit.dart';

typedef VoiceDataByLanguge = UnmodifiableMapView<String, Set<VoiceData>>;

class VoicesState extends Equatable {
  final String languageCode;
  final UnmodifiableSetView<String> allDownloaded, downloading;
  final UnmodifiableSetView<VoiceData> allAvailable;

  late final VoiceDataByLanguge availableByLanguage =
      VoiceDataByLanguge(allAvailable.groupSetsBy((element) => element.lang));
  late final Set<VoiceData> available = availableByLanguage[languageCode] ?? {};
  late final Set<String> downloaded =
      available.map((a) => a.name).toSet().intersection(allDownloaded);

  VoicesState({
    required this.languageCode,
    Iterable<String> allDownloaded = const {},
    Iterable<String> downloading = const {},
    Iterable<VoiceData> allAvailable = const {},
  })  : allDownloaded = UnmodifiableSetView(allDownloaded.toSet()),
        downloading = UnmodifiableSetView(downloading.toSet()),
        allAvailable = UnmodifiableSetView(allAvailable.toSet());

  VoicesState copyWith({
    String? languageCode,
    Iterable<String>? allDownloaded,
    Iterable<String>? downloading,
    Iterable<VoiceData>? allAvailable,
  }) =>
      VoicesState(
        languageCode: languageCode ?? this.languageCode,
        allDownloaded: allDownloaded ?? this.allDownloaded,
        downloading: downloading ?? this.downloading,
        allAvailable: allAvailable ?? this.allAvailable,
      );

  @override
  List<Object?> get props => [
        languageCode,
        allDownloaded,
        downloading,
        allAvailable,
      ];
}

class VoicesLoading extends VoicesState {
  VoicesLoading({required super.languageCode});

  @override
  VoicesState copyWith({
    String? languageCode,
    Iterable<String>? allDownloaded,
    Iterable<String>? downloading,
    Iterable<VoiceData>? allAvailable,
  }) =>
      VoicesLoading(languageCode: languageCode ?? this.languageCode);
}
