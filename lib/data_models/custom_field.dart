class CustomField {
  final int? id;
  final int? profileId;
  final String fieldKey;
  final String fieldValue;

  const CustomField({
    this.id,
    this.profileId,
    required this.fieldKey,
    required this.fieldValue,
  });

  const CustomField.draft({
    required this.fieldKey,
    required this.fieldValue,
  })  : id = null,
        profileId = null;

  factory CustomField.fromMap(Map<String, dynamic> map) {
    return CustomField(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int?,
      fieldKey: (map['field_key'] as String?) ?? '',
      fieldValue: (map['field_value'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap({int? overrideProfileId}) {
    return {
      if (id != null) 'id': id,
      'profile_id': overrideProfileId ?? profileId,
      'field_key': fieldKey.trim(),
      'field_value': fieldValue.trim(),
    };
  }

  Map<String, String> toExportJson() {
    return {
      'key': fieldKey.trim(),
      'value': fieldValue.trim(),
    };
  }

  CustomField copyWith({
    int? id,
    int? profileId,
    String? fieldKey,
    String? fieldValue,
  }) {
    return CustomField(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      fieldKey: fieldKey ?? this.fieldKey,
      fieldValue: fieldValue ?? this.fieldValue,
    );
  }
}
