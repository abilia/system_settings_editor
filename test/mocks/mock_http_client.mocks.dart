// Mocks generated by Mockito 5.0.16 from annotations
// in seagull/test/mocks/mock_http_client.dart.
// Do not manually edit this file.

import 'dart:async' as _i6;
import 'dart:convert' as _i5;
import 'dart:io' as _i4;

import 'package:http/http.dart' as _i7;
import 'package:http/src/byte_stream.dart' as _i2;
import 'package:http/src/multipart_file.dart' as _i8;
import 'package:http/src/streamed_response.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeUri_0 extends _i1.Fake implements Uri {}

class _FakeByteStream_1 extends _i1.Fake implements _i2.ByteStream {}

class _FakeStreamedResponse_2 extends _i1.Fake implements _i3.StreamedResponse {
}

class _FakeDuration_3 extends _i1.Fake implements Duration {}

class _FakeHttpClientRequest_4 extends _i1.Fake
    implements _i4.HttpClientRequest {}

class _FakeHttpHeaders_5 extends _i1.Fake implements _i4.HttpHeaders {}

class _FakeHttpClientResponse_6 extends _i1.Fake
    implements _i4.HttpClientResponse {}

class _FakeEncoding_7 extends _i1.Fake implements _i5.Encoding {}

class _FakeSocket_8 extends _i1.Fake implements _i4.Socket {}

class _FakeStreamSubscription_9<T> extends _i1.Fake
    implements _i6.StreamSubscription<T> {}

/// A class which mocks [MultipartRequest].
///
/// See the documentation for Mockito's code generation for more information.
class MockMultipartRequest extends _i1.Mock implements _i7.MultipartRequest {
  MockMultipartRequest() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<String, String> get fields =>
      (super.noSuchMethod(Invocation.getter(#fields),
          returnValue: <String, String>{}) as Map<String, String>);
  @override
  List<_i8.MultipartFile> get files =>
      (super.noSuchMethod(Invocation.getter(#files),
          returnValue: <_i8.MultipartFile>[]) as List<_i8.MultipartFile>);
  @override
  int get contentLength =>
      (super.noSuchMethod(Invocation.getter(#contentLength), returnValue: 0)
          as int);
  @override
  set contentLength(int? value) =>
      super.noSuchMethod(Invocation.setter(#contentLength, value),
          returnValueForMissingStub: null);
  @override
  String get method =>
      (super.noSuchMethod(Invocation.getter(#method), returnValue: '')
          as String);
  @override
  Uri get url =>
      (super.noSuchMethod(Invocation.getter(#url), returnValue: _FakeUri_0())
          as Uri);
  @override
  Map<String, String> get headers =>
      (super.noSuchMethod(Invocation.getter(#headers),
          returnValue: <String, String>{}) as Map<String, String>);
  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool);
  @override
  set persistentConnection(bool? value) =>
      super.noSuchMethod(Invocation.setter(#persistentConnection, value),
          returnValueForMissingStub: null);
  @override
  bool get followRedirects => (super
          .noSuchMethod(Invocation.getter(#followRedirects), returnValue: false)
      as bool);
  @override
  set followRedirects(bool? value) =>
      super.noSuchMethod(Invocation.setter(#followRedirects, value),
          returnValueForMissingStub: null);
  @override
  int get maxRedirects =>
      (super.noSuchMethod(Invocation.getter(#maxRedirects), returnValue: 0)
          as int);
  @override
  set maxRedirects(int? value) =>
      super.noSuchMethod(Invocation.setter(#maxRedirects, value),
          returnValueForMissingStub: null);
  @override
  bool get finalized =>
      (super.noSuchMethod(Invocation.getter(#finalized), returnValue: false)
          as bool);
  @override
  _i2.ByteStream finalize() =>
      (super.noSuchMethod(Invocation.method(#finalize, []),
          returnValue: _FakeByteStream_1()) as _i2.ByteStream);
  @override
  _i6.Future<_i3.StreamedResponse> send() =>
      (super.noSuchMethod(Invocation.method(#send, []),
              returnValue:
                  Future<_i3.StreamedResponse>.value(_FakeStreamedResponse_2()))
          as _i6.Future<_i3.StreamedResponse>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [HttpClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClient extends _i1.Mock implements _i4.HttpClient {
  MockHttpClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Duration get idleTimeout =>
      (super.noSuchMethod(Invocation.getter(#idleTimeout),
          returnValue: _FakeDuration_3()) as Duration);
  @override
  set idleTimeout(Duration? _idleTimeout) =>
      super.noSuchMethod(Invocation.setter(#idleTimeout, _idleTimeout),
          returnValueForMissingStub: null);
  @override
  set connectionTimeout(Duration? _connectionTimeout) => super.noSuchMethod(
      Invocation.setter(#connectionTimeout, _connectionTimeout),
      returnValueForMissingStub: null);
  @override
  set maxConnectionsPerHost(int? _maxConnectionsPerHost) => super.noSuchMethod(
      Invocation.setter(#maxConnectionsPerHost, _maxConnectionsPerHost),
      returnValueForMissingStub: null);
  @override
  bool get autoUncompress => (super
          .noSuchMethod(Invocation.getter(#autoUncompress), returnValue: false)
      as bool);
  @override
  set autoUncompress(bool? _autoUncompress) =>
      super.noSuchMethod(Invocation.setter(#autoUncompress, _autoUncompress),
          returnValueForMissingStub: null);
  @override
  set userAgent(String? _userAgent) =>
      super.noSuchMethod(Invocation.setter(#userAgent, _userAgent),
          returnValueForMissingStub: null);
  @override
  set authenticate(_i6.Future<bool> Function(Uri, String, String?)? f) =>
      super.noSuchMethod(Invocation.setter(#authenticate, f),
          returnValueForMissingStub: null);
  @override
  set findProxy(String Function(Uri)? f) =>
      super.noSuchMethod(Invocation.setter(#findProxy, f),
          returnValueForMissingStub: null);
  @override
  set authenticateProxy(
          _i6.Future<bool> Function(String, int, String, String?)? f) =>
      super.noSuchMethod(Invocation.setter(#authenticateProxy, f),
          returnValueForMissingStub: null);
  @override
  set badCertificateCallback(
          bool Function(_i4.X509Certificate, String, int)? callback) =>
      super.noSuchMethod(Invocation.setter(#badCertificateCallback, callback),
          returnValueForMissingStub: null);
  @override
  _i6.Future<_i4.HttpClientRequest> open(
          String? method, String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#open, [method, host, port, path]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> openUrl(String? method, Uri? url) =>
      (super.noSuchMethod(Invocation.method(#openUrl, [method, url]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> get(
          String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#get, [host, port, path]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> getUrl(Uri? url) => (super.noSuchMethod(
          Invocation.method(#getUrl, [url]),
          returnValue:
              Future<_i4.HttpClientRequest>.value(_FakeHttpClientRequest_4()))
      as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> post(
          String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#post, [host, port, path]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> postUrl(Uri? url) => (super.noSuchMethod(
          Invocation.method(#postUrl, [url]),
          returnValue:
              Future<_i4.HttpClientRequest>.value(_FakeHttpClientRequest_4()))
      as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> put(
          String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#put, [host, port, path]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> putUrl(Uri? url) => (super.noSuchMethod(
          Invocation.method(#putUrl, [url]),
          returnValue:
              Future<_i4.HttpClientRequest>.value(_FakeHttpClientRequest_4()))
      as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> delete(
          String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#delete, [host, port, path]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> deleteUrl(Uri? url) => (super.noSuchMethod(
          Invocation.method(#deleteUrl, [url]),
          returnValue:
              Future<_i4.HttpClientRequest>.value(_FakeHttpClientRequest_4()))
      as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> patch(
          String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#patch, [host, port, path]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> patchUrl(Uri? url) => (super.noSuchMethod(
          Invocation.method(#patchUrl, [url]),
          returnValue:
              Future<_i4.HttpClientRequest>.value(_FakeHttpClientRequest_4()))
      as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> head(
          String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#head, [host, port, path]),
              returnValue: Future<_i4.HttpClientRequest>.value(
                  _FakeHttpClientRequest_4()))
          as _i6.Future<_i4.HttpClientRequest>);
  @override
  _i6.Future<_i4.HttpClientRequest> headUrl(Uri? url) => (super.noSuchMethod(
          Invocation.method(#headUrl, [url]),
          returnValue:
              Future<_i4.HttpClientRequest>.value(_FakeHttpClientRequest_4()))
      as _i6.Future<_i4.HttpClientRequest>);
  @override
  void addCredentials(
          Uri? url, String? realm, _i4.HttpClientCredentials? credentials) =>
      super.noSuchMethod(
          Invocation.method(#addCredentials, [url, realm, credentials]),
          returnValueForMissingStub: null);
  @override
  void addProxyCredentials(String? host, int? port, String? realm,
          _i4.HttpClientCredentials? credentials) =>
      super.noSuchMethod(
          Invocation.method(
              #addProxyCredentials, [host, port, realm, credentials]),
          returnValueForMissingStub: null);
  @override
  void close({bool? force = false}) =>
      super.noSuchMethod(Invocation.method(#close, [], {#force: force}),
          returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
}

/// A class which mocks [HttpClientRequest].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClientRequest extends _i1.Mock implements _i4.HttpClientRequest {
  MockHttpClientRequest() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool);
  @override
  set persistentConnection(bool? _persistentConnection) => super.noSuchMethod(
      Invocation.setter(#persistentConnection, _persistentConnection),
      returnValueForMissingStub: null);
  @override
  bool get followRedirects => (super
          .noSuchMethod(Invocation.getter(#followRedirects), returnValue: false)
      as bool);
  @override
  set followRedirects(bool? _followRedirects) =>
      super.noSuchMethod(Invocation.setter(#followRedirects, _followRedirects),
          returnValueForMissingStub: null);
  @override
  int get maxRedirects =>
      (super.noSuchMethod(Invocation.getter(#maxRedirects), returnValue: 0)
          as int);
  @override
  set maxRedirects(int? _maxRedirects) =>
      super.noSuchMethod(Invocation.setter(#maxRedirects, _maxRedirects),
          returnValueForMissingStub: null);
  @override
  int get contentLength =>
      (super.noSuchMethod(Invocation.getter(#contentLength), returnValue: 0)
          as int);
  @override
  set contentLength(int? _contentLength) =>
      super.noSuchMethod(Invocation.setter(#contentLength, _contentLength),
          returnValueForMissingStub: null);
  @override
  bool get bufferOutput =>
      (super.noSuchMethod(Invocation.getter(#bufferOutput), returnValue: false)
          as bool);
  @override
  set bufferOutput(bool? _bufferOutput) =>
      super.noSuchMethod(Invocation.setter(#bufferOutput, _bufferOutput),
          returnValueForMissingStub: null);
  @override
  String get method =>
      (super.noSuchMethod(Invocation.getter(#method), returnValue: '')
          as String);
  @override
  Uri get uri =>
      (super.noSuchMethod(Invocation.getter(#uri), returnValue: _FakeUri_0())
          as Uri);
  @override
  _i4.HttpHeaders get headers =>
      (super.noSuchMethod(Invocation.getter(#headers),
          returnValue: _FakeHttpHeaders_5()) as _i4.HttpHeaders);
  @override
  List<_i4.Cookie> get cookies =>
      (super.noSuchMethod(Invocation.getter(#cookies),
          returnValue: <_i4.Cookie>[]) as List<_i4.Cookie>);
  @override
  _i6.Future<_i4.HttpClientResponse> get done => (super.noSuchMethod(
          Invocation.getter(#done),
          returnValue:
              Future<_i4.HttpClientResponse>.value(_FakeHttpClientResponse_6()))
      as _i6.Future<_i4.HttpClientResponse>);
  @override
  _i5.Encoding get encoding => (super.noSuchMethod(Invocation.getter(#encoding),
      returnValue: _FakeEncoding_7()) as _i5.Encoding);
  @override
  set encoding(_i5.Encoding? _encoding) =>
      super.noSuchMethod(Invocation.setter(#encoding, _encoding),
          returnValueForMissingStub: null);
  @override
  _i6.Future<_i4.HttpClientResponse> close() => (super.noSuchMethod(
          Invocation.method(#close, []),
          returnValue:
              Future<_i4.HttpClientResponse>.value(_FakeHttpClientResponse_6()))
      as _i6.Future<_i4.HttpClientResponse>);
  @override
  void abort([Object? exception, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#abort, [exception, stackTrace]),
          returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
  @override
  void add(List<int>? data) =>
      super.noSuchMethod(Invocation.method(#add, [data]),
          returnValueForMissingStub: null);
  @override
  void write(Object? object) =>
      super.noSuchMethod(Invocation.method(#write, [object]),
          returnValueForMissingStub: null);
  @override
  void writeAll(Iterable<dynamic>? objects, [String? separator = r'']) =>
      super.noSuchMethod(Invocation.method(#writeAll, [objects, separator]),
          returnValueForMissingStub: null);
  @override
  void writeln([Object? object = r'']) =>
      super.noSuchMethod(Invocation.method(#writeln, [object]),
          returnValueForMissingStub: null);
  @override
  void writeCharCode(int? charCode) =>
      super.noSuchMethod(Invocation.method(#writeCharCode, [charCode]),
          returnValueForMissingStub: null);
  @override
  void addError(Object? error, [StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#addError, [error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  _i6.Future<dynamic> addStream(_i6.Stream<List<int>>? stream) =>
      (super.noSuchMethod(Invocation.method(#addStream, [stream]),
          returnValue: Future<dynamic>.value()) as _i6.Future<dynamic>);
  @override
  _i6.Future<dynamic> flush() =>
      (super.noSuchMethod(Invocation.method(#flush, []),
          returnValue: Future<dynamic>.value()) as _i6.Future<dynamic>);
}

/// A class which mocks [HttpClientResponse].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClientResponse extends _i1.Mock
    implements _i4.HttpClientResponse {
  MockHttpClientResponse() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get statusCode =>
      (super.noSuchMethod(Invocation.getter(#statusCode), returnValue: 0)
          as int);
  @override
  String get reasonPhrase =>
      (super.noSuchMethod(Invocation.getter(#reasonPhrase), returnValue: '')
          as String);
  @override
  int get contentLength =>
      (super.noSuchMethod(Invocation.getter(#contentLength), returnValue: 0)
          as int);
  @override
  _i4.HttpClientResponseCompressionState get compressionState =>
      (super.noSuchMethod(Invocation.getter(#compressionState),
              returnValue: _i4.HttpClientResponseCompressionState.notCompressed)
          as _i4.HttpClientResponseCompressionState);
  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool);
  @override
  bool get isRedirect =>
      (super.noSuchMethod(Invocation.getter(#isRedirect), returnValue: false)
          as bool);
  @override
  List<_i4.RedirectInfo> get redirects =>
      (super.noSuchMethod(Invocation.getter(#redirects),
          returnValue: <_i4.RedirectInfo>[]) as List<_i4.RedirectInfo>);
  @override
  _i4.HttpHeaders get headers =>
      (super.noSuchMethod(Invocation.getter(#headers),
          returnValue: _FakeHttpHeaders_5()) as _i4.HttpHeaders);
  @override
  List<_i4.Cookie> get cookies =>
      (super.noSuchMethod(Invocation.getter(#cookies),
          returnValue: <_i4.Cookie>[]) as List<_i4.Cookie>);
  @override
  bool get isBroadcast =>
      (super.noSuchMethod(Invocation.getter(#isBroadcast), returnValue: false)
          as bool);
  @override
  _i6.Future<int> get length => (super.noSuchMethod(Invocation.getter(#length),
      returnValue: Future<int>.value(0)) as _i6.Future<int>);
  @override
  _i6.Future<bool> get isEmpty =>
      (super.noSuchMethod(Invocation.getter(#isEmpty),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<List<int>> get first => (super.noSuchMethod(
      Invocation.getter(#first),
      returnValue: Future<List<int>>.value(<int>[])) as _i6.Future<List<int>>);
  @override
  _i6.Future<List<int>> get last => (super.noSuchMethod(
      Invocation.getter(#last),
      returnValue: Future<List<int>>.value(<int>[])) as _i6.Future<List<int>>);
  @override
  _i6.Future<List<int>> get single => (super.noSuchMethod(
      Invocation.getter(#single),
      returnValue: Future<List<int>>.value(<int>[])) as _i6.Future<List<int>>);
  @override
  _i6.Future<_i4.HttpClientResponse> redirect(
          [String? method, Uri? url, bool? followLoops]) =>
      (super.noSuchMethod(
              Invocation.method(#redirect, [method, url, followLoops]),
              returnValue: Future<_i4.HttpClientResponse>.value(
                  _FakeHttpClientResponse_6()))
          as _i6.Future<_i4.HttpClientResponse>);
  @override
  _i6.Future<_i4.Socket> detachSocket() =>
      (super.noSuchMethod(Invocation.method(#detachSocket, []),
              returnValue: Future<_i4.Socket>.value(_FakeSocket_8()))
          as _i6.Future<_i4.Socket>);
  @override
  String toString() => super.toString();
  @override
  _i6.Stream<List<int>> asBroadcastStream(
          {void Function(_i6.StreamSubscription<List<int>>)? onListen,
          void Function(_i6.StreamSubscription<List<int>>)? onCancel}) =>
      (super.noSuchMethod(
          Invocation.method(#asBroadcastStream, [],
              {#onListen: onListen, #onCancel: onCancel}),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      (super.noSuchMethod(
              Invocation.method(#listen, [
                onData
              ], {
                #onError: onError,
                #onDone: onDone,
                #cancelOnError: cancelOnError
              }),
              returnValue: _FakeStreamSubscription_9<List<int>>())
          as _i6.StreamSubscription<List<int>>);
  @override
  _i6.Stream<List<int>> where(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#where, [test]),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.Stream<S> map<S>(S Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#map, [convert]),
          returnValue: Stream<S>.empty()) as _i6.Stream<S>);
  @override
  _i6.Stream<E> asyncMap<E>(_i6.FutureOr<E>? Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#asyncMap, [convert]),
          returnValue: Stream<E>.empty()) as _i6.Stream<E>);
  @override
  _i6.Stream<E> asyncExpand<E>(_i6.Stream<E>? Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#asyncExpand, [convert]),
          returnValue: Stream<E>.empty()) as _i6.Stream<E>);
  @override
  _i6.Stream<List<int>> handleError(Function? onError,
          {bool Function(dynamic)? test}) =>
      (super.noSuchMethod(
          Invocation.method(#handleError, [onError], {#test: test}),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.Stream<S> expand<S>(Iterable<S> Function(List<int>)? convert) =>
      (super.noSuchMethod(Invocation.method(#expand, [convert]),
          returnValue: Stream<S>.empty()) as _i6.Stream<S>);
  @override
  _i6.Future<dynamic> pipe(_i6.StreamConsumer<List<int>>? streamConsumer) =>
      (super.noSuchMethod(Invocation.method(#pipe, [streamConsumer]),
          returnValue: Future<dynamic>.value()) as _i6.Future<dynamic>);
  @override
  _i6.Stream<S> transform<S>(
          _i6.StreamTransformer<List<int>, S>? streamTransformer) =>
      (super.noSuchMethod(Invocation.method(#transform, [streamTransformer]),
          returnValue: Stream<S>.empty()) as _i6.Stream<S>);
  @override
  _i6.Future<List<int>> reduce(
          List<int> Function(List<int>, List<int>)? combine) =>
      (super.noSuchMethod(Invocation.method(#reduce, [combine]),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i6.Future<List<int>>);
  @override
  _i6.Future<S> fold<S>(S? initialValue, S Function(S, List<int>)? combine) =>
      (super.noSuchMethod(Invocation.method(#fold, [initialValue, combine]),
          returnValue: Future<S>.value(null)) as _i6.Future<S>);
  @override
  _i6.Future<String> join([String? separator = r'']) =>
      (super.noSuchMethod(Invocation.method(#join, [separator]),
          returnValue: Future<String>.value('')) as _i6.Future<String>);
  @override
  _i6.Future<bool> contains(Object? needle) =>
      (super.noSuchMethod(Invocation.method(#contains, [needle]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<dynamic> forEach(void Function(List<int>)? action) =>
      (super.noSuchMethod(Invocation.method(#forEach, [action]),
          returnValue: Future<dynamic>.value()) as _i6.Future<dynamic>);
  @override
  _i6.Future<bool> every(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#every, [test]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Future<bool> any(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#any, [test]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  _i6.Stream<R> cast<R>() => (super.noSuchMethod(Invocation.method(#cast, []),
      returnValue: Stream<R>.empty()) as _i6.Stream<R>);
  @override
  _i6.Future<List<List<int>>> toList() =>
      (super.noSuchMethod(Invocation.method(#toList, []),
              returnValue: Future<List<List<int>>>.value(<List<int>>[]))
          as _i6.Future<List<List<int>>>);
  @override
  _i6.Future<Set<List<int>>> toSet() =>
      (super.noSuchMethod(Invocation.method(#toSet, []),
              returnValue: Future<Set<List<int>>>.value(<List<int>>{}))
          as _i6.Future<Set<List<int>>>);
  @override
  _i6.Future<E> drain<E>([E? futureValue]) =>
      (super.noSuchMethod(Invocation.method(#drain, [futureValue]),
          returnValue: Future<E>.value(null)) as _i6.Future<E>);
  @override
  _i6.Stream<List<int>> take(int? count) =>
      (super.noSuchMethod(Invocation.method(#take, [count]),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.Stream<List<int>> takeWhile(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#takeWhile, [test]),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.Stream<List<int>> skip(int? count) =>
      (super.noSuchMethod(Invocation.method(#skip, [count]),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.Stream<List<int>> skipWhile(bool Function(List<int>)? test) =>
      (super.noSuchMethod(Invocation.method(#skipWhile, [test]),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.Stream<List<int>> distinct(
          [bool Function(List<int>, List<int>)? equals]) =>
      (super.noSuchMethod(Invocation.method(#distinct, [equals]),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
  @override
  _i6.Future<List<int>> firstWhere(bool Function(List<int>)? test,
          {List<int> Function()? orElse}) =>
      (super.noSuchMethod(
              Invocation.method(#firstWhere, [test], {#orElse: orElse}),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i6.Future<List<int>>);
  @override
  _i6.Future<List<int>> lastWhere(bool Function(List<int>)? test,
          {List<int> Function()? orElse}) =>
      (super.noSuchMethod(
              Invocation.method(#lastWhere, [test], {#orElse: orElse}),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i6.Future<List<int>>);
  @override
  _i6.Future<List<int>> singleWhere(bool Function(List<int>)? test,
          {List<int> Function()? orElse}) =>
      (super.noSuchMethod(
              Invocation.method(#singleWhere, [test], {#orElse: orElse}),
              returnValue: Future<List<int>>.value(<int>[]))
          as _i6.Future<List<int>>);
  @override
  _i6.Future<List<int>> elementAt(int? index) => (super.noSuchMethod(
      Invocation.method(#elementAt, [index]),
      returnValue: Future<List<int>>.value(<int>[])) as _i6.Future<List<int>>);
  @override
  _i6.Stream<List<int>> timeout(Duration? timeLimit,
          {void Function(_i6.EventSink<List<int>>)? onTimeout}) =>
      (super.noSuchMethod(
          Invocation.method(#timeout, [timeLimit], {#onTimeout: onTimeout}),
          returnValue: Stream<List<int>>.empty()) as _i6.Stream<List<int>>);
}

/// A class which mocks [HttpHeaders].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpHeaders extends _i1.Mock implements _i4.HttpHeaders {
  MockHttpHeaders() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set date(DateTime? _date) =>
      super.noSuchMethod(Invocation.setter(#date, _date),
          returnValueForMissingStub: null);
  @override
  set expires(DateTime? _expires) =>
      super.noSuchMethod(Invocation.setter(#expires, _expires),
          returnValueForMissingStub: null);
  @override
  set ifModifiedSince(DateTime? _ifModifiedSince) =>
      super.noSuchMethod(Invocation.setter(#ifModifiedSince, _ifModifiedSince),
          returnValueForMissingStub: null);
  @override
  set host(String? _host) => super.noSuchMethod(Invocation.setter(#host, _host),
      returnValueForMissingStub: null);
  @override
  set port(int? _port) => super.noSuchMethod(Invocation.setter(#port, _port),
      returnValueForMissingStub: null);
  @override
  set contentType(_i4.ContentType? _contentType) =>
      super.noSuchMethod(Invocation.setter(#contentType, _contentType),
          returnValueForMissingStub: null);
  @override
  int get contentLength =>
      (super.noSuchMethod(Invocation.getter(#contentLength), returnValue: 0)
          as int);
  @override
  set contentLength(int? _contentLength) =>
      super.noSuchMethod(Invocation.setter(#contentLength, _contentLength),
          returnValueForMissingStub: null);
  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool);
  @override
  set persistentConnection(bool? _persistentConnection) => super.noSuchMethod(
      Invocation.setter(#persistentConnection, _persistentConnection),
      returnValueForMissingStub: null);
  @override
  bool get chunkedTransferEncoding =>
      (super.noSuchMethod(Invocation.getter(#chunkedTransferEncoding),
          returnValue: false) as bool);
  @override
  set chunkedTransferEncoding(bool? _chunkedTransferEncoding) =>
      super.noSuchMethod(
          Invocation.setter(#chunkedTransferEncoding, _chunkedTransferEncoding),
          returnValueForMissingStub: null);
  @override
  List<String>? operator [](String? name) =>
      (super.noSuchMethod(Invocation.method(#[], [name])) as List<String>?);
  @override
  String? value(String? name) =>
      (super.noSuchMethod(Invocation.method(#value, [name])) as String?);
  @override
  void add(String? name, Object? value, {bool? preserveHeaderCase = false}) =>
      super.noSuchMethod(
          Invocation.method(
              #add, [name, value], {#preserveHeaderCase: preserveHeaderCase}),
          returnValueForMissingStub: null);
  @override
  void set(String? name, Object? value, {bool? preserveHeaderCase = false}) =>
      super.noSuchMethod(
          Invocation.method(
              #set, [name, value], {#preserveHeaderCase: preserveHeaderCase}),
          returnValueForMissingStub: null);
  @override
  void remove(String? name, Object? value) =>
      super.noSuchMethod(Invocation.method(#remove, [name, value]),
          returnValueForMissingStub: null);
  @override
  void removeAll(String? name) =>
      super.noSuchMethod(Invocation.method(#removeAll, [name]),
          returnValueForMissingStub: null);
  @override
  void forEach(void Function(String, List<String>)? action) =>
      super.noSuchMethod(Invocation.method(#forEach, [action]),
          returnValueForMissingStub: null);
  @override
  void noFolding(String? name) =>
      super.noSuchMethod(Invocation.method(#noFolding, [name]),
          returnValueForMissingStub: null);
  @override
  void clear() => super.noSuchMethod(Invocation.method(#clear, []),
      returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
}
