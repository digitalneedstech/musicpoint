import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_event.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_state.dart';
import 'package:spotify_2/pages/player/repos/player_track_repo.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/shared/models/tracks.dart';

class PlayerTracksBloc extends Bloc<PlayerTracksEvent, PlayerTrackState> {
  final Playlist playlist;
  final PlayerTrackRepository playerTrackRepository;
  PlayerTracksBloc({required this.playlist,
    required this.playerTrackRepository}) : super(PlayerTrackLoading()){
    on<PlayerTracksFetched>(
        _onPostFetched
    );
    on<PlayerTracksTrackSelected>(
      _onTrackSelected
    );
  }


  Future<void> _onPostFetched(
      PlayerTracksFetched event,
      Emitter<PlayerTrackState> emit,
      ) async {
    try {
      SharedPreferences preferences=await SharedPreferences.getInstance();
      late var authToken;
      if(preferences.containsKey("auth")){
        authToken=preferences.getString("auth");
      }
      final dynamic tracks = await playerTrackRepository.fetchTracks(authToken, playlist.id);
      if(tracks is List<Track>) {
        final currentTrack = tracks[0];

        emit(PlayerTracksSuccess(
            playlist: playlist,
            currentTrack: currentTrack,
            tracks: tracks.toList(growable: true),
            isAllDataLoaded: false));
      }
      else{
        emit(PlayerTrackError());
      }
      //add(PlayerTrackStoryTextAndArtistImageUrlLoaded());
    } catch (_) {
      emit(PlayerTrackError());
    }
  }

  Future<void> _onTrackSelected(
      PlayerTracksTrackSelected event,
      Emitter<PlayerTrackState> emit,
      ) async {
    try {
      final selectedTrack = event.tracks[event.selectedTrackIndex];
      if(event.state is PlayerTracksSuccess){
        PlayerTracksSuccess updatedState=event.state as PlayerTracksSuccess;
      emit(updatedState.copyWith(
          playlist: playlist,
          tracks: [],
          currentTrack: selectedTrack,
          currentTrackArtistImageUrl: '',
          storyText: '',
          isAllDataLoaded: false));
      }
    } catch (_) {
      emit(PlayerTrackError());
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
