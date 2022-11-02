import 'dart:io';

class Directories {
  final Directory applicationSupport, documents, temp;
  const Directories({
    required this.applicationSupport,
    required this.documents,
    required this.temp,
  });
}
