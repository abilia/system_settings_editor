import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';

class MockMultipartRequestBuilder extends Mock
    implements MultipartRequestBuilder {}

class MockMultipartRequest extends Mock implements MultipartRequest {}
