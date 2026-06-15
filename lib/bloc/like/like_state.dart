import '../../models/like_model.dart';

abstract class LikeState {}

class LikeInitial extends LikeState {}

class LikeLoading extends LikeState {}

class LikesLoaded extends LikeState {

  final Map<String, LikeModel?> userLikes;

  final Map<String, int> likeCounts;

  LikesLoaded(this.userLikes, this.likeCounts);
}

class LikeError extends LikeState {
  final String message;
  LikeError(this.message);
}
