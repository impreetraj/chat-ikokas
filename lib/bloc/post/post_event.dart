import '../../models/post_model.dart';

abstract class PostEvent {}

class LoadPosts extends PostEvent {}

class AddPost extends PostEvent {
  final PostModel post;
  AddPost(this.post);
}

class DeletePost extends PostEvent {
  final String postId;
  DeletePost(this.postId);
}

class UpdatePostReaction extends PostEvent {
  final String postId;
  final String postUserId;
  final String reaction;
  final int likeCount;
  UpdatePostReaction(this.postId, this.postUserId, this.reaction, this.likeCount);
}
