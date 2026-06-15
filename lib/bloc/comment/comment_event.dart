abstract class CommentEvent {}

class LoadComments extends CommentEvent {
  final String postId;
  LoadComments(this.postId);
}

class AddComment extends CommentEvent {
  final String postId;
  final String postUserId;
  final String authorName;
  final String content;

  AddComment(this.postId, this.postUserId, this.authorName, this.content);
}

class UpdateCommentReaction extends CommentEvent {
  final String commentId;
  final String postId;
  final String reaction;
  final int likeCount;

  UpdateCommentReaction(this.commentId, this.postId, this.reaction, this.likeCount);
}
