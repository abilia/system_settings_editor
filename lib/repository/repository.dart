import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

abstract class Repository extends Equatable {
  final String baseUrl;
  final BaseClient client;
  Repository(this.client, this.baseUrl)
      : assert(client is MockClient || baseUrl != null);
  @override
  List<Object> get props => [baseUrl, client];
  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $client}';
}
