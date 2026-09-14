import 'dart:convert';

/// The types a collection's custom field can have. `singleChoice` is also
/// how the built-in Catégorie/État default fields work — their option list
/// just lives directly on [CollectionSchema] instead of a [FieldDefinition].
enum FieldType { text, longText, integer, decimal, boolean, date, singleChoice, photo, url }

extension FieldTypeLabel on FieldType {
  String get label => switch (this) {
        FieldType.text => 'Texte',
        FieldType.longText => 'Texte long',
        FieldType.integer => 'Entier',
        FieldType.decimal => 'Décimal',
        FieldType.boolean => 'Booléen',
        FieldType.date => 'Date',
        FieldType.singleChoice => 'Choix unique',
        FieldType.photo => 'Photo',
        FieldType.url => 'Lien',
      };
}

/// One custom field a collection's items carry, beyond the 7 built-in
/// default fields (Nom, Catégorie, Photo, Quantité, Valeur estimée, État,
/// Notes — see docs/spec-universes-collections.md §3).
class FieldDefinition {
  final String key;
  final String label;
  final FieldType type;

  /// Only meaningful when [type] is [FieldType.singleChoice].
  final List<String> options;

  const FieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
  });

  factory FieldDefinition.fromJson(Map<String, dynamic> json) => FieldDefinition(
        key: json['key'] as String,
        label: json['label'] as String,
        type: FieldType.values.byName(json['type'] as String),
        options: (json['options'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'type': type.name,
        if (options.isNotEmpty) 'options': options,
      };
}

/// The user-defined shape of a Collection: which categories/states it
/// offers (used by the built-in Catégorie/État fields) and which extra
/// custom fields its items carry. Stored as JSON on `Collections.schemaJson`.
class CollectionSchema {
  final List<String> categories;
  final List<String> states;
  final List<FieldDefinition> customFields;

  const CollectionSchema({
    this.categories = const [],
    this.states = const [],
    this.customFields = const [],
  });

  static const defaultStates = [
    'Neuf',
    'Très bon état',
    'Bon état',
    'État moyen',
    'Abîmé',
  ];

  factory CollectionSchema.empty() => const CollectionSchema(states: defaultStates);

  factory CollectionSchema.fromJson(Map<String, dynamic> json) => CollectionSchema(
        categories: (json['categories'] as List?)?.cast<String>() ?? const [],
        states: (json['states'] as List?)?.cast<String>() ?? const [],
        customFields: (json['customFields'] as List?)
                ?.map((e) => FieldDefinition.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'categories': categories,
        'states': states,
        'customFields': customFields.map((f) => f.toJson()).toList(),
      };

  String encode() => jsonEncode(toJson());

  factory CollectionSchema.decode(String source) =>
      CollectionSchema.fromJson(jsonDecode(source) as Map<String, dynamic>);

  CollectionSchema copyWith({
    List<String>? categories,
    List<String>? states,
    List<FieldDefinition>? customFields,
  }) =>
      CollectionSchema(
        categories: categories ?? this.categories,
        states: states ?? this.states,
        customFields: customFields ?? this.customFields,
      );
}
