import '../services/contact_index.dart';
import 'contact_item.dart';
import 'custom_field.dart';

class UserProfile {
  final int? id;
  final String profileHash;
  final String name;
  final String? nickname;
  final String phoneNumber;
  final String? email;
  final String? birthday;
  final String notesToRemember;
  final List<String> likes;
  final List<String> dislikes;
  final List<String> hobbies;
  final String avatarIcon;
  final bool isFavorite;
  final bool isTrainingEnabled;
  final int createdAt;
  final int updatedAt;
  final List<CustomField> customFields;

  String get normalizedPhone => ContactIndex.normalizePhone(phoneNumber);

  const UserProfile({
    this.id,
    required this.profileHash,
    required this.name,
    this.nickname,
    required this.phoneNumber,
    this.email,
    this.birthday,
    this.notesToRemember = '',
    this.likes = const [],
    this.dislikes = const [],
    this.hobbies = const [],
    this.avatarIcon = 'user',
    this.isFavorite = false,
    this.isTrainingEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.customFields = const [],
  });

  factory UserProfile.fromContact({
    required ContactItem contact,
    required String profileHash,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return UserProfile(
      profileHash: profileHash,
      name: contact.displayName,
      phoneNumber: contact.phoneNumber,
      email: contact.email,
      avatarIcon: 'user',
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserProfile.empty({required String profileHash}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return UserProfile(
      profileHash: profileHash,
      name: '',
      phoneNumber: '',
      avatarIcon: 'user',
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserProfile.fromMap(
    Map<String, dynamic> map, {
    List<CustomField> customFields = const [],
  }) {
    return UserProfile(
      id: map['id'] as int?,
      profileHash: (map['profile_hash'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      nickname: map['nickname'] as String?,
      phoneNumber: (map['phone_number'] as String?) ?? '',
      email: map['email'] as String?,
      birthday: map['birthday'] as String?,
      notesToRemember: (map['notes_to_remember'] as String?) ?? '',
      likes: _parseCommaSeparated(map['likes'] as String?),
      dislikes: _parseCommaSeparated(map['dislikes'] as String?),
      hobbies: _parseCommaSeparated(map['hobbies'] as String?),
      avatarIcon: (map['avatar_icon'] as String?) ?? 'user',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      isTrainingEnabled: (map['is_training_enabled'] as int? ?? 1) == 1,
      createdAt: (map['created_at'] as int?) ?? 0,
      updatedAt: (map['updated_at'] as int?) ?? 0,
      customFields: customFields,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'profile_hash': profileHash,
      'name': name.trim(),
      'nickname': nickname?.trim(),
      'phone_number': phoneNumber.trim(),
      // Derived search-index columns (see ContactIndex); never read back.
      'phone_normalized': ContactIndex.normalizePhone(phoneNumber),
      'name_t9': ContactIndex.toT9(name),
      'email': email?.trim(),
      'birthday': birthday,
      'notes_to_remember': notesToRemember.trim(),
      'likes': _joinCommaSeparated(likes),
      'dislikes': _joinCommaSeparated(dislikes),
      'hobbies': _joinCommaSeparated(hobbies),
      'avatar_icon': avatarIcon,
      'is_favorite': isFavorite ? 1 : 0,
      'is_training_enabled': isTrainingEnabled ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Serializes profile into structured LLM context payload while omitting raw phone numbers for privacy.
  Map<String, dynamic> toExportJson() {
    return {
      'profile_hash': profileHash,
      'name': name.trim(),
      if (nickname != null && nickname!.trim().isNotEmpty)
        'nickname': nickname!.trim(),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (birthday != null && birthday!.isNotEmpty) 'birthday': birthday,
      'notes_to_remember': notesToRemember.trim(),
      'likes': likes,
      'dislikes': dislikes,
      'hobbies': hobbies,
      'avatar_icon': avatarIcon,
      'is_favorite': isFavorite,
      'custom_attributes': {
        for (final field in customFields)
          if (field.fieldKey.trim().isNotEmpty)
            field.fieldKey.trim(): field.fieldValue.trim(),
      },
      'updated_at': updatedAt,
    };
  }

  UserProfile copyWith({
    int? id,
    String? profileHash,
    String? name,
    String? nickname,
    String? phoneNumber,
    String? email,
    String? birthday,
    String? notesToRemember,
    List<String>? likes,
    List<String>? dislikes,
    List<String>? hobbies,
    String? avatarIcon,
    bool? isFavorite,
    bool? isTrainingEnabled,
    int? createdAt,
    int? updatedAt,
    List<CustomField>? customFields,
  }) {
    return UserProfile(
      id: id ?? this.id,
      profileHash: profileHash ?? this.profileHash,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      notesToRemember: notesToRemember ?? this.notesToRemember,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      hobbies: hobbies ?? this.hobbies,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      isFavorite: isFavorite ?? this.isFavorite,
      isTrainingEnabled: isTrainingEnabled ?? this.isTrainingEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFields: customFields ?? this.customFields,
    );
  }

  static List<String> _parseCommaSeparated(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _joinCommaSeparated(List<String> items) {
    return items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
  }
}
