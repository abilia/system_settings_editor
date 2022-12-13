import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';

import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  testWidgets('hidden reset button', (tester) async {
    // Arrange
    final voiceDb = MockVoiceDb();
    when(() => voiceDb.textToSpeech).thenReturn(true);
    when(() => voiceDb.voice).thenReturn('test voice');
    when(() => voiceDb.speakEveryWord).thenReturn(true);
    when(() => voiceDb.speechRate).thenReturn(0);
    when(() => voiceDb.setVoice(any())).thenAnswer((_) async {});
    when(() => voiceDb.setTextToSpeech(any())).thenAnswer((_) async {});
    when(() => voiceDb.setSpeakEveryWord(any())).thenAnswer((_) async {});
    when(() => voiceDb.setSpeechRate(any())).thenAnswer((_) async {});
    final speechSettingsCubit = SpeechSettingsCubit(
      voiceDb: voiceDb,
      acapelaTts: FakeTtsHandler(),
    );

    final voiceRepository = MockVoiceRepository();
    when(() => voiceRepository.deleteAllVoices()).thenAnswer((_) async {});
    when(() => voiceRepository.readAvailableVoices())
        .thenAnswer((_) async => []);
    when(() => voiceRepository.readDownloadedVoices())
        .thenAnswer((_) async => []);

    final voicesCubit = VoicesCubit(
      languageCode: 'en',
      speechSettingsCubit: speechSettingsCubit,
      voiceRepository: voiceRepository,
      localeStream: const Stream.empty(),
    );

    final deviceRepository = MockDeviceRepository();
    when(() => deviceRepository.setStartGuideCompleted(any()))
        .thenAnswer((_) async {});
    when(() => deviceRepository.serialId).thenReturn('expected');
    when(() => deviceRepository.isStartGuideCompleted).thenReturn(true);

    final startupCubit = StartupCubit(
      deviceRepository: deviceRepository,
      connectivityChanged: const Stream.empty(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SpeechSettingsCubit>.value(value: speechSettingsCubit),
            BlocProvider.value(value: voicesCubit),
            BlocProvider.value(value: startupCubit),
          ],
          child: const AbiliaLogoWithReset(),
        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();
    await tester.longPress(find.byType(AbiliaLogoWithReset));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(YesButton));
    await tester.pumpAndSettle();

    // Assert
    verify(() => voiceRepository.deleteAllVoices()).called(1);
    verify(() => voiceDb.setVoice('')).called(1);
    verify(() => voiceDb.setSpeakEveryWord(false)).called(1);
    verify(() => voiceDb.setSpeechRate(VoiceDb.defaultSpeechRate)).called(1);
    verify(() => voiceDb.setTextToSpeech(false)).called(1);
    verify(() => deviceRepository.setStartGuideCompleted(false)).called(1);
  }, skip: !Config.isMP);
}
