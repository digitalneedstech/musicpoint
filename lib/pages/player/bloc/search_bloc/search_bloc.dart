import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_event.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_state.dart';
import 'package:spotify_2/pages/player/repos/player_track_repo.dart';
import 'package:spotify_2/shared/models/tracks.dart';

class SearchBloc extends Bloc<PlayerTracksEvent, PlayerTrackState> {
  final PlayerTrackRepository playerTrackRepository;
  SearchBloc({
    required this.playerTrackRepository}) : super(PlayerTrackLoading()){

    on<FetchSongsForSearchQuery>(
        _onSearchSelection
    );


  }

  Future<void> _onSearchSelection(
      FetchSongsForSearchQuery event,
      Emitter<PlayerTrackState> emit,
      ) async {
    try {
      emit(PlayerTrackLoading());
      SharedPreferences preferences=await SharedPreferences.getInstance();
      late String? authToken;
      if(preferences.containsKey("auth")){
        authToken=preferences.getString("auth");
      }
      final dynamic tracks = await playerTrackRepository.fetchSearchTracks(authToken!, event.query);
      if(tracks is List<Track>) {
        emit(SearchTracksSuccess(
          tracks: tracks.isEmpty ? []:tracks.toList(growable: true),
        ));
      }
      else{
        emit(PlayerTrackError());
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
