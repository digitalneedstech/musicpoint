import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/shared/models/tracks.dart';

@immutable
abstract class PlayerTrackState extends Equatable {
  const PlayerTrackState();
}

class PlayerTrackLoading extends PlayerTrackState {
  @override
  List<Object> get props => [];
}

class PlayerTracksSuccess extends PlayerTrackState {
  final List<Track> tracks;
  final Track currentTrack;
  final Playlist playlist;
  final String currentTrackArtistImageUrl;
  final String storyText;
  final bool isAllDataLoaded;
  const PlayerTracksSuccess({
    required this.playlist,
    required this.tracks,
    required this.currentTrack,
    this.currentTrackArtistImageUrl = '',
    this.storyText="",
    this.isAllDataLoaded = false,
  });

  PlayerTracksSuccess copyWith(
      {required List<Track> tracks,
        required Playlist playlist,
        required Track currentTrack,
        required String currentTrackArtistImageUrl,
        required String storyText,
        required bool isAllDataLoaded}) =>
      PlayerTracksSuccess(
          tracks: tracks,
          playlist: playlist,
          currentTrack: currentTrack,
          currentTrackArtistImageUrl:
          currentTrackArtistImageUrl,
          storyText: storyText,
          isAllDataLoaded: isAllDataLoaded);

  @override
  List<Object> get props => [];
}

class SearchTracksSuccess extends PlayerTrackState {
  final List<Track> tracks;
  const SearchTracksSuccess({
    required this.tracks
  });

  SearchTracksSuccess copyWith(
      {required List<Track> tracks}) =>
      SearchTracksSuccess(
          tracks: tracks);

  @override
  List<Object> get props => [];
}

class PlayerTrackError extends PlayerTrackState {
  @override
  List<Object> get props => [];
}
