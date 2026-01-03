import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'user_dao.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'residents.db');

    return await openDatabase(
      path,
      version: 10,
      onCreate: (db, version) async {
        await _createActivityLogsTable(db);
        await _createGateEntriesTable(db);
        await _createResidentsTable(db);
        await _createVehiclesTable(db);
        await _createUsersTable(db);
        await UserDao().insertDefaultAdmin();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if(oldVersion < 4){
          await _createGateEntriesTable(db);
        }
        if(oldVersion < 5){
          await _updateResidentsTable(db);
        }
        if (oldVersion < 6) {
          await _addImagePathToResidents(db); // Adding Image Support
        }
        if (oldVersion < 7) {
          await _createVehiclesTable(db); //residents vehicle table
        }
        if (oldVersion < 8) {
          await _createUsersTable(db);
          await _createActivityLogsTable(db);
          await UserDao().insertDefaultAdmin();
        }
        if (oldVersion < 9) {
          await _addRecordedByToGateEntries(db);
          await _addRecordedByToResidents(db);
        }
        if (oldVersion < 10) {
          await _addRecorderIdColumns(db);
        }
      },
    );
  }

  // Create Residents Table
  Future<void> _createResidentsTable(Database db)async {
    await db.execute('''
          CREATE TABLE residents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            house_num TEXT,
            resident_type TEXT,
            mobile TEXT,
            uuid TEXT,
            image_path TEXT,
            recorded_by TEXT,
            recorded_by_id INTEGER,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
    // High-performance optimization for 100,000+ residents:
    await db.execute('CREATE INDEX IF NOT EXISTS idx_res_uuid ON residents (uuid)');
  }

  // Add UUID Column to Residents Table
  Future<void> _updateResidentsTable(Database db) async {
    // Use try-catch or check if column exists to prevent "duplicate column" crashes
    try {
      await db.execute('ALTER TABLE residents ADD COLUMN uuid TEXT');
    } catch (e) {
      print("Column uuid might already exist: $e");
    }

    // Backfill existing rows with UUIDs
    List<Map<String, dynamic>> results = await db.query('residents');
    for (var row in results) {
      // If uuid is null or empty string, generate one
      if (row['uuid'] == null || row['uuid'].toString().isEmpty) {
        String newUuid = const Uuid().v4();
        await db.update(
          'residents',
          {'uuid': newUuid},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
    print("Migration complete: UUIDs generated for existing records.");
  }

  // Add Image Path Column to Residents Table
  Future<void> _addImagePathToResidents(Database db) async {
    try {
      // Adds the column to the existing table
      await db.execute('ALTER TABLE residents ADD COLUMN image_path TEXT');
      print("Migration complete: Added image_path column to residents.");
    } catch (e) {
      print("Column image_path might already exist: $e");
    }
  }

  // Create Gate Entries Table
  Future<void> _createGateEntriesTable(Database db)async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS gate_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          person_name TEXT,
          mobile TEXT,
          person_type TEXT,
          purpose TEXT,
          house_num TEXT,
          resident_type TEXT,
          vehicle_no TEXT,
          entry_time TEXT,
          exit_time TEXT,
          qr_code TEXT,
          remarks TEXT,
          recorded_by TEXT,
          recorded_by_id INTEGER,
          created_at TEXT,
          updated_at TEXT
        )
        ''');
  }

  // Create Vehicles Table
  Future _createVehiclesTable(Database db) async {
    await db.execute('''
      CREATE TABLE residents_vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resident_id INTEGER,
        vehicle_number TEXT NOT NULL,
        vehicle_type TEXT,
        vehicle_color TEXT,
        vehicle_model TEXT,
        recorded_by TEXT,
        recorded_by_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (resident_id) REFERENCES residents (id) ON DELETE CASCADE
      )
    ''');
  }

  // Create Users Table
  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        full_name TEXT,
        role TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Create Activity Logs Table
  Future<void> _createActivityLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        resident_id INTEGER,
        action TEXT, -- 'SCANNED', 'EDITED', 'ADDED_VEHICLE'
        timestamp TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');
  }

  // Add Recorded By Column to Gate Entries
  Future<void> _addRecordedByToGateEntries(Database db) async {
    try {
      await db.execute('ALTER TABLE gate_entries ADD COLUMN recorded_by TEXT');
      print("Migration complete: Added recorded_by column to gate_entries.");
    } catch (e) {
      print("Column recorded_by might already exist: $e");
    }
  }

  // Add Recorded By Column to Residents
  Future<void> _addRecordedByToResidents(Database db) async {
    try {
      await db.execute('ALTER TABLE residents ADD COLUMN recorded_by TEXT');
      print("Migration complete: Added recorded_by to residents.");
    } catch (e) {
      print("Column recorded_by might already exist in residents: $e");
    }
  }

  // Add Recorder ID Columns
  Future<void> _addRecorderIdColumns(Database db) async {
    try {
      // Gate Entries
      await db.execute('ALTER TABLE gate_entries ADD COLUMN recorded_by_id INTEGER');

      // Residents
      await db.execute('ALTER TABLE residents ADD COLUMN recorded_by_id INTEGER');

      // Vehicles
      await db.execute('ALTER TABLE residents_vehicles ADD COLUMN recorded_by TEXT');
      await db.execute('ALTER TABLE residents_vehicles ADD COLUMN recorded_by_id INTEGER');

      print("Migration complete: Added recorder ID columns to all tables.");
    } catch (e) {
      print("Error in version 10 migration: $e");
    }
  }
}
