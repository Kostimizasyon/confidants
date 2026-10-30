import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data_models/call_entry.dart';
import '../data_models/user_profile.dart';
import 'contact_index.dart';
import 'database_helper.dart';

class CallLogService {
  static const MethodChannel _channel =
      MethodChannel('com.tozaring.confidants/call_log');

  static final CallLogService instance = CallLogService._internal();

  CallLogService._internal();

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    try {
      final result = await _channel.invokeMethod<bool>('hasCallLogPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    try {
      final result =
          await _channel.invokeMethod<bool>('requestCallLogPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<CallEntry>> getCallLogs({int limit = 100}) async {
    if (!isSupported) return const [];
    try {
      final raw = await _channel.invokeListMethod<dynamic>(
        'getCallLogs',
        {'limit': limit},
      );
      if (raw == null || raw.isEmpty) return const [];

      // Query local Confidants to cross-match phone numbers.
      final profiles = await DatabaseHelper.instance.getAllProfiles();
      final Map<String, UserProfile> phoneMap = {};
      for (final p in profiles) {
        final norm = p.normalizedPhone;
        if (norm.isNotEmpty) {
          phoneMap[norm] = p;
        }
      }

      final List<CallEntry> entries = [];
      for (final item in raw) {
        if (item is Map) {
          final number = item['number']?.toString() ?? '';
          final normNumber = ContactIndex.normalizePhone(number);

          // Attempt exact normalized phone lookup or suffix lookup for country code differences.
          UserProfile? matched = phoneMap[normNumber];
          if (matched == null && normNumber.length >= 7) {
            for (final entry in phoneMap.entries) {
              if (entry.key.endsWith(normNumber) ||
                  normNumber.endsWith(entry.key)) {
                matched = entry.value;
                break;
              }
            }
          }

          entries.add(CallEntry.fromMap(item, matchedConfidant: matched));
        }
      }
      return entries;
    } catch (_) {
      return const [];
    }
  }
}
