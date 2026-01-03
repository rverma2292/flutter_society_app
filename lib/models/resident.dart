import 'package:uuid/uuid.dart'; // Add this import

class Resident {
  final int? id;
  final String uuid;
  final String name;
  final String house_num;
  final String resident_type;
  final String mobile;
  final String? image_path;
  final String? recordedBy;
  final int? recordedById;
  final String? created_at;
  final String? updated_at;

  Resident({
    this.id,
    String? uuid,
    required this.name,
    required this.house_num,
    required this.resident_type,
    required this.mobile,
    this.image_path,
    this.recordedBy,
    this.recordedById,
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
      'image_path': image_path,
      'recorded_by': recordedBy,
      'recorded_by_id': recordedById,
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
    String? mobile,
    String? image_path,
    String? recordedBy,
    int? recordedById,
  }) {
    return Resident(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      house_num: house_num ?? this.house_num,
      resident_type: resident_type ?? this.resident_type,
      mobile: mobile ?? this.mobile,
      image_path: image_path ?? this.image_path,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedById: recordedById ?? this.recordedById,
      created_at: this.created_at,
      updated_at: this.updated_at,
    );
  }


  factory Resident.fromMap(Map<String, dynamic> map) {
    return Resident(
      id: map['id'],
      uuid: map['uuid'],
      name: map['name'] ?? '',
      house_num: map['house_num'] ?? '',
      resident_type: map['resident_type'] ?? '',
      mobile: map['mobile'] ?? '',
      image_path: map['image_path'],
      recordedBy: map['recorded_by'],      // DB se load kiya
      recordedById: map['recorded_by_id'], // DB se load kiya
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
    image_path TEXT, 
    recorded_by TEXT,
    recorded_by_id INTEGER,
    created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'))
  )
  ''';
}