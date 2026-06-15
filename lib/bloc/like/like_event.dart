abstract class LikeEvent {}

class ToggleLike extends LikeEvent {
  final String postId;
  final String postUserId;
  final String reaction;

  ToggleLike(this.postId, this.postUserId, this.reaction);
}

class LoadLikes extends LikeEvent {
  final List<String> postIds;

  LoadLikes(this.postIds);
}

class ClearLikes extends LikeEvent {}
