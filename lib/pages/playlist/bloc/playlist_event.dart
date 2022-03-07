
import 'package:equatable/equatable.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_state.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/shared/models/tracks.dart';

abstract class PlaylistEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PlaylistFetched extends PlaylistEvent {}



class SearchPlayerTracksTrackSelected extends PlaylistEvent {
  final int selectedTrackIndex;
  final List<Track> tracks;
  final PlayerTrackState state;
  SearchPlayerTracksTrackSelected({required this.state,required this.tracks,required this.selectedTrackIndex});

  @override
  List<Object> get props => [selectedTrackIndex];
}



class SearchPlayerTracksSuccess extends PlayerTrackState {
  final List<Track> tracks;
  final Track currentTrack;
  final String currentTrackArtistImageUrl;
  final String storyText;
  final bool isAllDataLoaded;
  const SearchPlayerTracksSuccess({
    required this.tracks,
    required this.currentTrack,
    this.currentTrackArtistImageUrl = '',
    this.storyText="",
    this.isAllDataLoaded = false,
  });

  SearchPlayerTracksSuccess copyWith(
      {required List<Track> tracks,
        required Track currentTrack,
        required String currentTrackArtistImageUrl,
        required String storyText,
        required bool isAllDataLoaded}) =>
      SearchPlayerTracksSuccess(
          tracks: tracks,
          currentTrack: currentTrack,
          currentTrackArtistImageUrl:
          currentTrackArtistImageUrl,
          storyText: storyText,
          isAllDataLoaded: isAllDataLoaded);

  @override
  List<Object> get props => [];
}


class SearchPlayerTrackError extends PlayerTrackState {
  @override
  List<Object> get props => [];
}
