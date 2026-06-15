class CommentModel {
  final String? id;
  final String postId;
  final String authorName;
  final String authorPhotoUrl;
  final String content;
  final String timestamp;
  final String? reaction;
  final int likeCount;

  CommentModel({
    this.id,
    required this.postId,
    required this.authorName,
    this.authorPhotoUrl = '',
    required this.content,
    required this.timestamp,
    this.reaction,
    this.likeCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'timestamp': timestamp,
      'reaction': reaction,
      'likeCount': likeCount,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      postId: map['postId'],
      authorName: map['authorName'],
      authorPhotoUrl: map['authorPhotoUrl'] ?? '',
      content: map['content'],
      timestamp: map['timestamp'],
      reaction: map['reaction'],
      likeCount: map['likeCount'] ?? 0,
    );
  }
}
