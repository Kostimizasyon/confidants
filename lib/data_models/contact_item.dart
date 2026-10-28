class ContactItem {
  final String displayName;
  final String phoneNumber;
  final String? email;

  const ContactItem({
    required this.displayName,
    required this.phoneNumber,
    this.email,
  });

  const ContactItem.phoneOnly({
    required this.displayName,
    required this.phoneNumber,
  }) : email = null;

  factory ContactItem.fromMap(Map<String, dynamic> map) {
    return ContactItem(
      displayName: (map['display_name'] as String?) ?? '',
      phoneNumber: (map['phone_number'] as String?) ?? '',
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'phone_number': phoneNumber,
      'email': email,
    };
  }
}
