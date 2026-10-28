import 'dart:convert';
import 'package:crypto/crypto.dart';

abstract final class HashService {
  // Normalizes phone numbers/identifiers before hashing so formatting differences resolve to the same SHA-256 key.
  static String hashIdentifier(String rawIdentifier) {
    final digitsOnly = rawIdentifier.replaceAll(RegExp(r'[^0-9+]'), '');
    final normalized = digitsOnly.isNotEmpty
        ? digitsOnly
        : rawIdentifier.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    return sha256.convert(bytes).toString();
  }

  static String computeChecksum(String payload) {
    final bytes = utf8.encode(payload);
    return sha256.convert(bytes).toString();
  }
}
