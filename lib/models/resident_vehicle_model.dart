class ResidentVehicle {
  final int? id;
  final int residentId;
  final String vehicleNumber; // Required
  final String? vehicleType;   // Nullable
  final String? vehicleColor;  // Nullable
  final String? vehicleModel;  // Nullable
  final String? createdAt;
  final String? updatedAt;

  ResidentVehicle({
    this.id,
    required this.residentId,
    required this.vehicleNumber, // Required
    this.vehicleType,            // Now Optional
    this.vehicleColor,           // Now Optional
    this.vehicleModel,           // Now Optional
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
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
