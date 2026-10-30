/// Pure, dependency-free helpers for phone indexing, T9 name matching, and
/// Samsung One UI-style contact section grouping.
class ContactIndex {
  ContactIndex._();

  /// Section key for names starting with emojis, symbols, or unparsed characters.
  static const String symbolSection = '&';

  /// Section key for names starting with digits (0–9) or ASCII punctuation.
  static const String numberSection = '#';

  /// Letters printed under each dial pad digit.
  static const Map<String, String> keypadLetters = {
    '1': '',
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
    '*': '',
    '0': '+',
    '#': '',
  };

  // Folds accented / Turkish Latin letters to their base A–Z letter.
  static const Map<String, String> _latinFold = {
    'ç': 'c', 'ğ': 'g', 'ı': 'i', 'İ': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
    'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u',
    'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
  };

  static const Map<String, String> _letterToDigit = {
    'a': '2', 'b': '2', 'c': '2',
    'd': '3', 'e': '3', 'f': '3',
    'g': '4', 'h': '4', 'i': '4',
    'j': '5', 'k': '5', 'l': '5',
    'm': '6', 'n': '6', 'o': '6',
    'p': '7', 'q': '7', 'r': '7', 's': '7',
    't': '8', 'u': '8', 'v': '8',
    'w': '9', 'x': '9', 'y': '9', 'z': '9',
  };

  static const String _asciiPunctuation = r'''!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~''';

  /// Strips spaces and symbols so `+90 (555) 010-99 99` becomes `905550109999`.
  static String normalizePhone(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9]'), '');

  /// Strips everything except characters the dial pad can type.
  static String sanitizeDialInput(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9+*#]'), '');

  /// Folds a single character to lowercase base Latin (`Ş` → `s`).
  static String foldChar(String char) {
    if (char == 'İ') return 'i';
    final lower = char.toLowerCase();
    return _latinFold[lower] ?? lower;
  }

  /// Folds a whole string for accent-insensitive sorting.
  static String foldString(String raw) =>
      raw.split('').map(foldChar).join();

  /// Converts a name into its T9 digit form, keeping word boundaries as spaces.
  /// `Ali Şahin` → `254 72446`.
  static String toT9(String name) {
    final buffer = StringBuffer();
    for (final char in name.trim().split('')) {
      if (char.trim().isEmpty) {
        if (buffer.isNotEmpty && !buffer.toString().endsWith(' ')) {
          buffer.write(' ');
        }
        continue;
      }
      final folded = foldChar(char);
      final digit = _letterToDigit[folded];
      if (digit != null) {
        buffer.write(digit);
      } else if (RegExp(r'[0-9]').hasMatch(folded)) {
        buffer.write(folded);
      }
    }
    return buffer.toString().trim();
  }

  /// Returns `&`, `A`–`Z`, or `#` following the Samsung One UI ordering rules.
  static String sectionKeyFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return symbolSection;

    final firstRune = trimmed.runes.first;
    final firstChar = String.fromCharCode(firstRune);

    if (RegExp(r'[0-9]').hasMatch(firstChar) ||
        _asciiPunctuation.contains(firstChar)) {
      return numberSection;
    }

    final folded = foldChar(firstChar);
    if (RegExp(r'^[a-z]$').hasMatch(folded)) {
      return folded.toUpperCase();
    }

    return symbolSection;
  }

  /// Sort weight: `&` first, `A`–`Z` in the middle, `#` last.
  static int sectionOrder(String key) {
    if (key == symbolSection) return 0;
    if (key == numberSection) return 27;
    return key.codeUnitAt(0) - 64; // 'A' -> 1 ... 'Z' -> 26
  }

  /// Groups items into ordered sections, sorting each section by folded name.
  static List<MapEntry<String, List<T>>> groupBySection<T>(
    Iterable<T> items,
    String Function(T item) nameOf,
  ) {
    final grouped = <String, List<T>>{};
    for (final item in items) {
      grouped.putIfAbsent(sectionKeyFor(nameOf(item)), () => []).add(item);
    }

    for (final list in grouped.values) {
      list.sort(
        (a, b) => foldString(nameOf(a).trim())
            .compareTo(foldString(nameOf(b).trim())),
      );
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => sectionOrder(a.key).compareTo(sectionOrder(b.key)));
    return entries;
  }

  /// Returns the A–Z initial to render in an avatar, or `null` when the name
  /// starts with an emoji, symbol, or digit.
  static String? avatarInitialFor(String name) {
    final key = sectionKeyFor(name);
    if (key == symbolSection || key == numberSection) return null;
    return String.fromCharCode(name.trim().runes.first).toUpperCase();
  }
}
