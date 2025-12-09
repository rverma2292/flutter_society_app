class Resident {
  final int? id;
  final String name;
  final String flat;
  final String block;
  final String mobile;
  final String? created_at; // इसे nullable बनाएं
  final String? updated_at; // इसे nullable बनाएं

  Resident({
    this.id,
    required this.name,
    required this.flat,
    required this.block,
    required this.mobile,
    this.created_at, // इसे अब required नहीं है
    this.updated_at, // इसे अब required नहीं है
  });

  Map<String, dynamic> toMap() {
    // वर्तमान समय को ISO 8601 स्ट्रिंग फॉर्मेट में प्राप्त करें
    final String now = DateTime.now().toIso8601String();

    return {
      'id': id,
      'name': name,
      'flat': flat,
      'block': block,
      'mobile': mobile,
      // यदि created_at null है (नया रिकॉर्ड), तो वर्तमान समय सेट करें, अन्यथा मौजूदा मान का उपयोग करें
      'created_at': created_at ?? now,
      // हमेशा वर्तमान समय के साथ updated_at को अपडेट करें
      'updated_at': now,
    };
  }

  factory Resident.fromMap(Map<String, dynamic> map) {
    return Resident(
      id: map['id'],
      name: map['name'] ?? '',
      flat: map['flat'] ?? '',
      block: map['block'] ?? '',
      mobile: map['mobile'] ?? '',
      created_at: map['created_at'],
      // ये पहले से ही nullable हैं, इसलिए ?? '' की आवश्यकता नहीं है
      updated_at: map['updated_at'],
    );
  }

  static const String createTable = '''
  CREATE TABLE residents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    flat TEXT NOT NULL,
    block TEXT NOT NULL,
    mobile TEXT NOT NULL UNIQUE,
    -- CURRENT_TIMESTAMP को डिफ़ॉल्ट मान के रूप में सेट करें
    created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'))
  )
  ''';
}