class ResidentVehicle {
  final int? id;
  final int residentId;
  final String vehicleNumber;
  final String? vehicleType;
  final String? vehicleColor;
  final String? vehicleModel;
  final String? recordedBy;
  final int? recordedById;
  final String? createdAt;
  final String? updatedAt;

  ResidentVehicle({
    this.id,
    required this.residentId,
    required this.vehicleNumber,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleModel,
    this.recordedBy,
    this.recordedById,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resident_id': residentId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'vehicle_color': vehicleColor,
      'vehicle_model': vehicleModel,
      'recorded_by': recordedBy,
      'recorded_by_id': recordedById,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory ResidentVehicle.fromMap(Map<String, dynamic> map) {
    return ResidentVehicle(
      id: map['id'],
      residentId: map['resident_id'],
      vehicleNumber: map['vehicle_number'],
      vehicleType: map['vehicle_type'],
      vehicleColor: map['vehicle_color'],
      vehicleModel: map['vehicle_model'],
      recordedBy: map['recorded_by'],
      recordedById: map['recorded_by_id'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
