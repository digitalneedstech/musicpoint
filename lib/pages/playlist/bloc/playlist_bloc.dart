
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_event.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/pages/playlist/bloc/playlist_event.dart';
import 'package:spotify_2/pages/playlist/bloc/playlist_state.dart';
import 'package:spotify_2/pages/playlist/repos/playlist_repo.dart';
import 'package:spotify_2/shared/models/tracks.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository playlistRepository;
  PlaylistBloc({required this.playlistRepository}) : super(const PlaylistState()) {
    on<PlaylistFetched>(
      _onPostFetched
    );
  }

  int start = 0;
  int currentSongTimeDuration=0;

  Future<void> _onPostFetched(
      PlaylistFetched event,
      Emitter<PlaylistState> emit,
      ) async {
    try {
      if (state.status == PlaylistStatus.initial) {
        SharedPreferences preferences=await SharedPreferences.getInstance();
        late var authToken;
        if(preferences.containsKey("auth")){
          authToken=preferences.getString("auth");
        }
        try {
          dynamic response = await playlistRepository.fetchPlayList(
              authToken.toString());
          if (response is List<Playlist>){
            return emit(state.copyWith(
              status: PlaylistStatus.success,
              posts: response
            ));
          }
          else {
            return emit(state.copyWith(
                status: PlaylistStatus.success,
                posts: []
            ));
          }
        }
        catch(e){
          return emit(state.copyWith(
              status: PlaylistStatus.failure,
              posts: []
          ));
        }
      }

    } catch (_) {
      emit(state.copyWith(status: PlaylistStatus.failure));
    }
  }


  Future<void> close() async {
    print("Bloc closed");
    super.close();
  }
}
