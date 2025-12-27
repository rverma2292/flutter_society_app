import 'package:uuid/uuid.dart'; // Add this import

class Resident {
  final int? id;
  final String uuid;
  final String name;
  final String house_num;
  final String resident_type;
  final String mobile;
  final String? created_at; //nullable
  final String? updated_at; //nullable

  Resident({
    this.id,
    String? uuid, // Added this
    required this.name,
    required this.house_num,
    required this.resident_type,
    required this.mobile,
    this.created_at,
    this.updated_at,
  }): this.uuid = uuid ?? const Uuid().v4();

  Map<String, dynamic> toMap() {

    final String now = DateTime.now().toIso8601String();

    return {
      'id': id,
      'uuid': uuid, // Added this
      'name': name,
      'house_num': house_num,
      'resident_type': resident_type,
      'mobile': mobile,
      'created_at': created_at ?? now,
      'updated_at': now,
    };
  }

  Resident copyWith({
    int? id,
    String? uuid, // Added this
    String? name,
    String? house_num,
    String? resident_type,
    String? mobile
  }) {
    return Resident(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid, // Added this
      name: name ?? this.name,
      house_num: house_num ?? this.house_num,
      resident_type: resident_type ?? this.resident_type,
      mobile: mobile ?? this.mobile,
      created_at: this.created_at,
      updated_at: this.updated_at,
    );
  }


  factory Resident.fromMap(Map<String, dynamic> map) {
    return Resident(
      id: map['id'],
      uuid: map['uuid'], // Added this
      name: map['name'] ?? '',
      house_num: map['house_num'] ?? '',
      resident_type: map['resident_type'] ?? '',
      mobile: map['mobile'] ?? '',
      created_at: map['created_at'],
      updated_at: map['updated_at'],
    );
  }

  static const String createTable = '''
  CREATE TABLE residents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT NOT NULL,
    name TEXT NOT NULL,
    house_num TEXT NOT NULL,
    resident_type TEXT NOT NULL,
    mobile TEXT NOT NULL UNIQUE,
    -- CURRENT_TIMESTAMP
    created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'))
  )
  ''';
}