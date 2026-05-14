import 'package:equatable/equatable.dart';

/// Events for the [RecommendationBloc].
abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger AI recommendation generation based on finished books.
class FetchRecommendations extends RecommendationEvent {}
