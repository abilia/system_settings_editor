import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

abstract class Repository extends Equatable {
  final String baseUrl;
  final BaseClient httpClient;
  Repository(this.httpClient, this.baseUrl)
      : assert(httpClient is MockClient || baseUrl != null);
  @override
  List<Object> get props => [baseUrl, httpClient];
  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $httpClient}';
}
