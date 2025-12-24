class GateEntry {
  final int? id;
  final String personName;
  final String mobile;
  final String personType; // e.g., Visitor, Delivery, Guest
  final String purpose;
  final String houseNum;
  final String? residentType;
  final String? vehicleNo;
  final String entryTime;
  final String? exitTime;
  final String? qrCode;
  final String? remarks;
  final String? createdAt;
  final String? updatedAt;

  GateEntry({
    this.id,
    required this.personName,
    required this.mobile,
    required this.personType,
    required this.purpose,
    required this.houseNum,
    this.residentType,
    this.vehicleNo,
    required this.entryTime,
    this.exitTime,
    this.qrCode,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  // Convert a GateEntry into a Map. The keys must match the DB column names.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_name': personName,
      'mobile': mobile,
      'person_type': personType,
      'purpose': purpose,
      'house_num': houseNum,
      'resident_type': residentType,
      'vehicle_no': vehicleNo,
      'entry_time': entryTime,
      'exit_time': exitTime,
      'qr_code': qrCode,
      'remarks': remarks,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  // Extract a GateEntry object from a Map.
  factory GateEntry.fromMap(Map<String, dynamic> map) {
    return GateEntry(
      id: map['id'],
      personName: map['person_name'],
      mobile: map['mobile'],
      personType: map['person_type'],
      purpose: map['purpose'],
      houseNum: map['house_num'],
      residentType: map['resident_type'],
      vehicleNo: map['vehicle_no'],
      entryTime: map['entry_time'],
      exitTime: map['exit_time'],
      qrCode: map['qr_code'],
      remarks: map['remarks'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
