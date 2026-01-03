
class ActivityLogModel {
  final int? id;
  final int userId;
  final int? referenceId;
  final String action;
  final String timestamp;

  // Extra fields for UI (Jo JOIN se aayenge)
  final String? guardName;
  final String? residentName;

  ActivityLogModel({
    this.id,
    required this.userId,
    this.referenceId,
    required this.action,
    required this.timestamp,
    this.guardName,
    this.residentName,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'],
      userId: map['user_id'],
      referenceId: map['reference_id'],
      action: map['action'],
      timestamp: map['timestamp'],
      guardName: map['guard_name'], // Database query se join hoke aayega
      residentName: map['resident_name'], // Database query se join hoke aayega
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'reference_id': referenceId,
      'action': action,
      'timestamp': timestamp,
    };
  }
}
