import 'dart:io';

import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:transparent_image/transparent_image.dart';

import 'mock_http_client.mocks.dart';

@GenerateMocks([
  MultipartRequest,
  HttpClient,
  HttpClientRequest,
  HttpClientResponse,
  HttpHeaders,
])
R provideMockedNetworkImages<R>(R Function() body) => HttpOverrides.runZoned(
      body,
      createHttpClient: (_) => createMockImageHttpClient(kTransparentImage),
    );

// Returns a mock HTTP client that responds with an image to all requests.
MockHttpClient createMockImageHttpClient(List<int> imageBytes) {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  when(client.getUrl(any))
      .thenAnswer((_) => Future<HttpClientRequest>.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close())
      .thenAnswer((_) => Future<HttpClientResponse>.value(response));
  when(response.contentLength).thenReturn(imageBytes.length);
  when(response.statusCode).thenReturn(HttpStatus.ok);
  when(response.compressionState)
      .thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(response.listen(
    any,
    onError: anyNamed('onError'),
    onDone: anyNamed('onDone'),
    cancelOnError: anyNamed('cancelOnError'),
  )).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData = invocation.positionalArguments[0];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final void Function(Object, [StackTrace?]) onError =
        invocation.namedArguments[#onError];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return Stream<List<int>>.fromIterable(<List<int>>[imageBytes]).listen(
        onData,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError);
  });

  return client;
}
