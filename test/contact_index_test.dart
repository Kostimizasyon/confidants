import 'package:confidants/services/contact_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phone normalization', () {
    test('strips spaces, dashes, parentheses and plus sign', () {
      expect(ContactIndex.normalizePhone('+90 (555) 010-99 99'), '905550109999');
      expect(ContactIndex.normalizePhone(''), '');
    });

    test('dial input keeps only dialable characters', () {
      expect(ContactIndex.sanitizeDialInput('+90 555*1#a'), '+90555*1#');
    });
  });

  group('T9 conversion', () {
    test('maps letters to keypad digits and keeps word boundaries', () {
      expect(ContactIndex.toT9('Ali'), '254');
      expect(ContactIndex.toT9('Ali Şahin'), '254 72446');
    });

    test('folds Turkish letters', () {
      expect(ContactIndex.toT9('Çağrı'), ContactIndex.toT9('Cagri'));
    });
  });

  group('Samsung One UI section keys', () {
    test('letters map to A–Z (with Turkish folding)', () {
      expect(ContactIndex.sectionKeyFor('Ali'), 'A');
      expect(ContactIndex.sectionKeyFor('babam'), 'B');
      expect(ContactIndex.sectionKeyFor('Şule'), 'S');
      expect(ContactIndex.sectionKeyFor('İrem'), 'I');
    });

    test('digits and punctuation map to #', () {
      expect(ContactIndex.sectionKeyFor('112 Acil'), '#');
      expect(ContactIndex.sectionKeyFor('.dot'), '#');
      expect(ContactIndex.sectionKeyFor('(Work)'), '#');
    });

    test('emojis, symbols and other scripts map to &', () {
      expect(ContactIndex.sectionKeyFor('😏👾🤑'), '&');
      expect(ContactIndex.sectionKeyFor('★ Star'), '&');
      expect(ContactIndex.sectionKeyFor('Мария'), '&');
      expect(ContactIndex.sectionKeyFor(''), '&');
    });

    test('groups are ordered & first, A–Z, # last, sorted within', () {
      final names = ['Zeynep', '42', '😏', 'ali', 'Annem', 'Babam'];
      final groups = ContactIndex.groupBySection<String>(names, (n) => n);
      expect(groups.map((g) => g.key).toList(), ['&', 'A', 'B', 'Z', '#']);
      expect(groups[1].value, ['ali', 'Annem']);
    });

    test('avatar initial only for A–Z names', () {
      expect(ContactIndex.avatarInitialFor('annem'), 'A');
      expect(ContactIndex.avatarInitialFor('😏'), isNull);
      expect(ContactIndex.avatarInitialFor('42'), isNull);
    });
  });
}
