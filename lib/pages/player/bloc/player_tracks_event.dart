import 'package:equatable/equatable.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_state.dart';
import 'package:spotify_2/shared/models/tracks.dart';

abstract class PlayerTracksEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PlayerTracksFetched extends PlayerTracksEvent {}


class SearchTracksLoaded extends PlayerTracksEvent {}

class FetchSongsForSearchQuery extends PlayerTracksEvent {
  final String query;
  FetchSongsForSearchQuery({required this.query});

  @override
  List<Object> get props => [query];
}

class PlayerTracksTrackSelected extends PlayerTracksEvent {
  final int selectedTrackIndex;
  final List<Track> tracks;
  final PlayerTrackState state;
  PlayerTracksTrackSelected({required this.state,required this.tracks,required this.selectedTrackIndex});

  @override
  List<Object> get props => [selectedTrackIndex];
}

class PlayerTrackStoryTextAndArtistImageUrlLoaded extends PlayerTracksEvent {}

class PlayerTrackStoryTextUpdated extends PlayerTracksEvent {
  final String storyText;

  PlayerTrackStoryTextUpdated(this.storyText);

  @override
  List<Object> get props => [storyText];
}
