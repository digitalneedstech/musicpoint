
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/shared/models/tracks.dart';

@immutable
abstract class PlayListState extends Equatable {
  const PlayListState();
}
enum PlaylistStatus { initial, success, failure }

class PlaylistState extends Equatable {
  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.playlist = const <Playlist>[]
  });

  final PlaylistStatus status;
  final List<Playlist> playlist;

  PlaylistState copyWith({
    PlaylistStatus? status,
    List<Playlist>? posts,
    bool? hasReachedMax,
  }) {
    return PlaylistState(
      status: status ?? this.status,
      playlist: posts ?? this.playlist
    );
  }

  @override
  String toString() {
    return '';
  }

  @override
  List<Object> get props => [status];
}


class SearchTracksSuccess extends PlaylistState {
  final List<Track> tracks;
  final String errorMessage;
  const SearchTracksSuccess({
    required this.tracks,
    required this.errorMessage
  });

  @override
  List<Object> get props => [];
}

