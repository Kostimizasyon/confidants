import 'package:flutter_contacts/flutter_contacts.dart';
import '../data_models/contact_item.dart';

class ContactService {
  static final ContactService instance = ContactService();

  Future<bool> requestContactPermission() async {
    return FlutterContacts.requestPermission(readonly: true);
  }

  Future<List<ContactItem>> fetchDeviceContacts() async {
    final hasPermission = await requestContactPermission();
    if (!hasPermission) return const [];

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    final items = <ContactItem>[];
    for (final contact in contacts) {
      if (contact.phones.isEmpty) continue;
      final primaryPhone = contact.phones.first.number.trim();
      if (primaryPhone.isEmpty) continue;

      final displayName = contact.displayName.trim().isNotEmpty
          ? contact.displayName.trim()
          : primaryPhone;
      final primaryEmail = contact.emails.isNotEmpty
          ? contact.emails.first.address.trim()
          : null;

      items.add(
        ContactItem(
          displayName: displayName,
          phoneNumber: primaryPhone,
          email: (primaryEmail != null && primaryEmail.isNotEmpty)
              ? primaryEmail
              : null,
        ),
      );
    }

    return items;
  }

  Future<bool> insertDeviceContact({
    required String name,
    required String phoneNumber,
    String? email,
    String? notes,
  }) async {
    try {
      final hasPermission =
          await FlutterContacts.requestPermission(readonly: false);
      if (!hasPermission) return false;

      final trimmedName = name.trim();
      final contact = Contact();
      final lastSpace = trimmedName.lastIndexOf(' ');
      if (lastSpace > 0) {
        contact.name.first = trimmedName.substring(0, lastSpace);
        contact.name.last = trimmedName.substring(lastSpace + 1);
      } else {
        contact.name.first = trimmedName;
      }

      if (phoneNumber.trim().isNotEmpty) {
        contact.phones = [Phone(phoneNumber.trim())];
      }
      if (email != null && email.trim().isNotEmpty) {
        contact.emails = [Email(email.trim())];
      }
      if (notes != null && notes.trim().isNotEmpty) {
        contact.notes = [Note(notes.trim())];
      }

      await contact.insert();
      return true;
    } catch (_) {
      return false;
    }
  }
}
