import 'user_profile.dart';

enum CallType {
  incoming,
  outgoing,
  missed,
  rejected,
  blocked,
  unknown;

  static CallType fromString(String? value) {
    switch (value) {
      case 'incoming':
        return CallType.incoming;
      case 'outgoing':
        return CallType.outgoing;
      case 'missed':
        return CallType.missed;
      case 'rejected':
        return CallType.rejected;
      case 'blocked':
        return CallType.blocked;
      default:
        return CallType.unknown;
    }
  }
}

class CallEntry {
  final String id;
  final String number;
  final String? cachedName;
  final CallType type;
  final DateTime timestamp;
  final Duration duration;
  final UserProfile? matchedConfidant;

  const CallEntry({
    required this.id,
    required this.number,
    this.cachedName,
    required this.type,
    required this.timestamp,
    this.duration = Duration.zero,
    this.matchedConfidant,
  });

  factory CallEntry.fromMap(Map<dynamic, dynamic> map, {UserProfile? matchedConfidant}) {
    final rawTimestamp = map['timestamp'];
    final millis = rawTimestamp is int
        ? rawTimestamp
        : (rawTimestamp is num ? rawTimestamp.toInt() : 0);
    final timestamp = millis > 0
        ? DateTime.fromMillisecondsSinceEpoch(millis)
        : DateTime.now();

    final rawDuration = map['duration'];
    final durationSec = rawDuration is int
        ? rawDuration
        : (rawDuration is num ? rawDuration.toInt() : 0);

    return CallEntry(
      id: map['id']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
      cachedName: map['name']?.toString(),
      type: CallType.fromString(map['type']?.toString()),
      timestamp: timestamp,
      duration: Duration(seconds: durationSec),
      matchedConfidant: matchedConfidant,
    );
  }

  CallEntry copyWith({
    String? id,
    String? number,
    String? cachedName,
    CallType? type,
    DateTime? timestamp,
    Duration? duration,
    UserProfile? matchedConfidant,
  }) {
    return CallEntry(
      id: id ?? this.id,
      number: number ?? this.number,
      cachedName: cachedName ?? this.cachedName,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      matchedConfidant: matchedConfidant ?? this.matchedConfidant,
    );
  }

  String get displayTitle {
    if (matchedConfidant != null && matchedConfidant!.name.trim().isNotEmpty) {
      return matchedConfidant!.name.trim();
    }
    if (cachedName != null && cachedName!.trim().isNotEmpty) {
      return cachedName!.trim();
    }
    if (number.trim().isNotEmpty) {
      return number.trim();
    }
    return '';
  }
}
