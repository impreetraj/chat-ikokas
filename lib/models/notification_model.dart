class NotificationModel {
  final int? id;
  final String message;
  final String timestamp;

  NotificationModel({
    this.id,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }
}
