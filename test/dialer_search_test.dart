import 'package:confidants/data_models/user_profile.dart';
import 'package:confidants/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await databaseFactory.deleteDatabase(
      '${await getDatabasesPath()}/confidants.db',
    );
  });

  UserProfile profile(String name, String phone) => UserProfile(
        profileHash: '$name-$phone',
        name: name,
        phoneNumber: phone,
        createdAt: 0,
        updatedAt: 0,
      );

  test('dialer matches phone digits, T9 names, and exact normalized phone', () async {
    final db = DatabaseHelper.instance;
    await db.saveProfile(profile('Ali Şahin', '+90 (555) 010-1234'));
    await db.saveProfile(profile('Annem', '0532 111 22 33'));
    await db.saveProfile(profile('Babam', '0533 999 88 77'));

    // Phone digits anywhere in the number.
    final byDigits = await db.searchForDialer('0101');
    expect(byDigits.map((p) => p.name), ['Ali Şahin']);

    // T9: "254" = A-L-I, "724" = Ş-A-H (second word).
    expect((await db.searchForDialer('254')).map((p) => p.name), ['Ali Şahin']);
    expect((await db.searchForDialer('724')).map((p) => p.name), ['Ali Şahin']);
    // "2" matches both A-names and B (B is on 2 too).
    expect((await db.searchForDialer('2')).length, 3);

    // Exact lookup ignores formatting.
    final exact = await db.findProfileByPhone('05321112233');
    expect(exact?.name, 'Annem');
  });
}
