import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/repository/all.dart';

import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  final translate = Locales.language.values.first;
  late final VoicesCubit voicesCubit;
  late final SpeechSettingsCubit speechSettingsCubit;
  late final StartupCubit startupCubit;
  late final BaseUrlCubit baseUrlCubit;
  late final VoiceRepository voiceRepository;
  late final DeviceRepository deviceRepository;
  late final BaseUrlDb baseUrlDb;
  late final VoiceDb voiceDb;
  final mockConnectivity = MockConnectivity();
  late MockMyAbiliaConnection mockMyAbiliaConnection;
  bool Function() factoryResetResponse = () => true;

  setUpAll(() async {
    voiceDb = MockVoiceDb();
    when(() => voiceDb.textToSpeech).thenReturn(true);
    when(() => voiceDb.voice).thenReturn('test voice');
    when(() => voiceDb.speakEveryWord).thenReturn(true);
    when(() => voiceDb.speechRate).thenReturn(0);
    when(() => voiceDb.setVoice(any())).thenAnswer((_) async {});
    when(() => voiceDb.setTextToSpeech(any())).thenAnswer((_) async {});
    when(() => voiceDb.setSpeakEveryWord(any())).thenAnswer((_) async {});
    when(() => voiceDb.setSpeechRate(any())).thenAnswer((_) async {});
    speechSettingsCubit = SpeechSettingsCubit(
      voiceDb: voiceDb,
      acapelaTts: FakeTtsHandler(),
    );

    voiceRepository = MockVoiceRepository();
    when(() => voiceRepository.deleteAllVoices()).thenAnswer((_) async {});
    when(() => voiceRepository.readAvailableVoices())
        .thenAnswer((_) async => []);
    when(() => voiceRepository.readDownloadedVoices())
        .thenAnswer((_) async => []);

    voicesCubit = VoicesCubit(
      languageCode: 'en',
      speechSettingsCubit: speechSettingsCubit,
      voiceRepository: voiceRepository,
      localeStream: const Stream.empty(),
    );

    deviceRepository = MockDeviceRepository();
    when(() => deviceRepository.setStartGuideCompleted(any()))
        .thenAnswer((_) async {});
    when(() => deviceRepository.serialId).thenReturn('expected');
    when(() => deviceRepository.isStartGuideCompleted).thenReturn(true);

    startupCubit = StartupCubit(deviceRepository: deviceRepository);

    baseUrlDb = MockBaseUrlDb();
    when(() => baseUrlDb.baseUrl).thenAnswer((_) => 'url');
    when(() => baseUrlDb.clearBaseUrl()).thenAnswer((_) async => true);

    baseUrlCubit = BaseUrlCubit(baseUrlDb: baseUrlDb);

    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value(ConnectivityResult.none));
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.none));

    mockMyAbiliaConnection = MockMyAbiliaConnection();
    when(() => mockMyAbiliaConnection.hasConnection())
        .thenAnswer((invocation) async => true);
  });

  setUp(() async {
    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..client = Fakes.client(
        factoryResetResponse: () => factoryResetResponse(),
      )
      ..init();
  });

  tearDown(() {
    factoryResetResponse = () => true;
    GetIt.I.reset();
  });

  final redButtonFinder = find.byType(RedButton);
  final cancelButtonFinder = find.byType(LightGreyButton);

  Future<void> pumpAbiliaLogoWithReset(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<DeviceRepository>(
          create: (context) => deviceRepository,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: speechSettingsCubit),
              BlocProvider.value(value: voicesCubit),
              BlocProvider.value(value: startupCubit),
              BlocProvider.value(value: baseUrlCubit),
              BlocProvider.value(value: FakeSpeechSettingsCubit()),
              BlocProvider.value(
                value: ConnectivityCubit(
                  connectivity: mockConnectivity,
                  baseUrlDb: FakeBaseUrlDb(),
                  myAbiliaConnection: mockMyAbiliaConnection,
                ),
              ),
            ],
            child: AbiliaLogoWithReset(
              deviceRepository: deviceRepository,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> goToConfirmFactoryReset(WidgetTester tester) async {
    await tester.longPress(find.byType(AbiliaLogoWithReset));
    await tester.pumpAndSettle();
    await tester.tap(find.text(translate.factoryReset));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RedButton));
    await tester.pumpAndSettle();
  }

  group('Clear data', () {
    testWidgets('Clear memoplanner data', (tester) async {
      // Arrange
      await pumpAbiliaLogoWithReset(tester);

      // Act
      await tester.pumpAndSettle();
      await tester.longPress(find.byType(AbiliaLogoWithReset));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.clearData));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(RedButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => voiceRepository.deleteAllVoices()).called(1);
      verify(() => voiceDb.setVoice('')).called(1);
      verify(() => voiceDb.setSpeakEveryWord(false)).called(1);
      verify(() => voiceDb.setSpeechRate(VoiceDb.defaultSpeechRate)).called(1);
      verify(() => voiceDb.setTextToSpeech(false)).called(1);
      verify(() => deviceRepository.setStartGuideCompleted(false)).called(1);
      verify(() => baseUrlDb.clearBaseUrl()).called(1);
    });
  }, skip: !Config.isMP);

  group('Factory reset', () {
    testWidgets('Factory reset device success shows spinner', (tester) async {
      // Arrange
      factoryResetResponse = () => true;
      await pumpAbiliaLogoWithReset(tester);
      await goToConfirmFactoryReset(tester);

      // Act
      await tester.tap(redButtonFinder);
      await tester.pump(5.minutes());

      // Assert
      expect(find.byType(AbiliaProgressIndicator), findsOneWidget);
      expect(
          tester.widget<RedButton>(redButtonFinder).onPressed == null, isTrue);
      expect(
          tester.widget<LightGreyButton>(cancelButtonFinder).onPressed == null,
          isTrue);
    });

    testWidgets('Factory reset device unexpected error shows error text',
        (tester) async {
      // Arrange
      factoryResetResponse = () => false;
      await pumpAbiliaLogoWithReset(tester);
      await goToConfirmFactoryReset(tester);

      // Act
      await tester.tap(redButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(translate.factoryResetFailed), findsOneWidget);
    });

    testWidgets(
        'Factory reset device no internet disables factory reset button',
        (tester) async {
      // Arrange
      when(() => mockMyAbiliaConnection.hasConnection())
          .thenAnswer((invocation) async => false);
      await pumpAbiliaLogoWithReset(tester);
      await goToConfirmFactoryReset(tester);

      // Act
      await tester.tap(redButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(translate.connectInternetToContinue), findsOneWidget);
      expect(
          tester.widget<RedButton>(redButtonFinder).onPressed == null, isTrue);
    });
  }, skip: !Config.isMP);
}
