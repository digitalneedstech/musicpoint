import 'package:equatable/equatable.dart';
import 'package:spotify_2/shared/models/playback.dart';
abstract class CurrentPlaybackEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CurrentPlaybackLoaded extends CurrentPlaybackEvent {}

class CurrentPlaybackPlayed extends CurrentPlaybackEvent {
  final int positionMs;

  CurrentPlaybackPlayed({this.positionMs = 0});

  @override
  List<Object> get props => [positionMs];
}

class CurrentPlaybackUpdated extends CurrentPlaybackEvent {
  final Playback playback;

  CurrentPlaybackUpdated(this.playback);

  @override
  List<Object> get props => [playback];
}

class CurrentPlaybackTrackChanged extends CurrentPlaybackEvent {}

class CurrentPlaybackPaused extends CurrentPlaybackEvent {}

class CurrentPlaybackAppPaused extends CurrentPlaybackEvent {}

class CurrentPlaybackAppResumed extends CurrentPlaybackEvent {}
