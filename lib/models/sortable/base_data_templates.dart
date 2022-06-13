class BaseDataTemplate {
  final String id, name, language;
  final int templateId;
  BaseDataTemplate({
    required this.id,
    required this.templateId,
    required this.name,
    required this.language,
  });

  factory BaseDataTemplate.fromJson(json) => BaseDataTemplate(
        id: json['id'],
        templateId: json['templateId'],
        name: json['name'],
        language: json['language'],
      );
}
