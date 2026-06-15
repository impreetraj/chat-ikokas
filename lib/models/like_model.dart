class LikeModel {
  final String? id;
  final String postId;
  final String userId;
  final String reaction;
  final String timestamp;

  LikeModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.reaction,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'reaction': reaction,
      'timestamp': timestamp,
    };
  }

  factory LikeModel.fromMap(Map<String, dynamic> map, String docId) {
    return LikeModel(
      id: docId,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      reaction: map['reaction'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }
}
