import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:spotify_2/pages/player/bloc/player_track_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_event.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_state.dart';
import 'package:spotify_2/pages/player/repos/player_track_repo.dart';
import 'package:spotify_2/pages/player/songs_list.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/shared/models/tracks.dart';
import 'package:spotify_2/shared/widgets/overlay_model/custom_rounded_button.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class PlayerPage extends StatefulWidget {
  final Function callback;
  const PlayerPage({required this.callback,this.isOpenedFromDeepLink = false});
  final bool isOpenedFromDeepLink;
  @override
  _PlayerState createState() => _PlayerState();

  static Widget create(
      {required Playlist playlist,required Function callback, bool isOpenedFromDeepLink = false}) {
    return BlocProvider(
      create: (_) => PlayerTracksBloc(
        playlist: playlist,playerTrackRepository: new PlayerTrackRepository(dio: Dio())
      )..add(PlayerTracksFetched()),
      child: PlayerPage(
        callback: callback,
              isOpenedFromDeepLink: isOpenedFromDeepLink,

            )
    );
  }
}

class _PlayerState extends State<PlayerPage> with WidgetsBindingObserver {
  late PlayerTracksBloc _playerTracksBloc;
  //late CurrentPlaybackBloc _currentPlaybackBloc;
  late ScrollController _controller;
  late CarouselController _carouselController;
  TextEditingController _textEditingController=TextEditingController(text: "");
  late List<Track> _tracks;
  late int _currentIndexPlayed;
  bool _isPlaylistPlaying = false;
  late Timer _timer;
  int _currentSongTimeDuration=0;
  bool _isNextSongApiCallCompleted=false;
  bool isSwitchEnabled=true;
  final GlobalKey<ScaffoldState> _scaffoldKey=GlobalKey();

  bool _isFromSearch=false;

  @override
  void initState(){
    super.initState();
    super.initState();
    _controller = ScrollController();
    _carouselController = CarouselController();
    _playerTracksBloc = BlocProvider.of<PlayerTracksBloc>(context);
    startTimer();
  }

  @override
  void dispose(){
    _timer.cancel();
    pause();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if(_currentSongTimeDuration!=0 && timer.tick>=_currentSongTimeDuration && isSwitchEnabled) {
          _isFromSearch ?skipNext():check();
        }
      },
    );
  }

  Future<void> playFromSearch(String type, String uri,String title,String artist) async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:$type:$uri');
      setState(() {
        _timer.cancel();
        startTimer();
        _isFromSearch=true;
        _isPlaylistPlaying = true;
        _currentSongTimeDuration=0;
        _isNextSongApiCallCompleted=false;
      });
      _fetchCurrentSongsTimeDuration(title, artist);
    } on PlatformException catch (e) {
      print(e);
      _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(e.message.toString())));
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      print("hi");
      //setStatus('not implemented');
    }
  }

  Future<void> play(String type, String uri,String title,String artist,List<Track> tracks, int index) async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:$type:$uri');
      setState(() {
        _timer.cancel();
        startTimer();
        _isPlaylistPlaying = true;
        _currentSongTimeDuration=0;
        _tracks=tracks;
        _currentIndexPlayed=index;
        _isNextSongApiCallCompleted=false;
      });
      _fetchCurrentSongsTimeDuration(title, artist);
    } on PlatformException catch (e) {
      print(e);
      _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(e.message.toString())));
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      print("hi");
      //setStatus('not implemented');
    }
  }

  void _fetchCurrentSongsTimeDuration(String title, String artist) {
    _playerTracksBloc.playerTrackRepository.fetchTimeDurationUntillCurrentTrackIsPlayed(title, artist)
    .then((value) {
      if (value is String) {
        String timestamp = value;
        int totalSeconds = int.parse(
            timestamp.split(":")[0]) * 60 +
            int.parse(
                (timestamp.split(":")[1]).split(".")[0]);
        if(totalSeconds==0){
          _isFromSearch ?skipNext():
          check();
        }else {
          setState(() {
            _currentSongTimeDuration = totalSeconds;
            _isNextSongApiCallCompleted=true;
          });
        }
      }
      else if(value is bool){
        _isFromSearch ?skipNext():
        check();
      }
    });
  }

  check(){
    if(_tracks.length>_currentIndexPlayed) {
      var index=_currentIndexPlayed;
      index++;
      if(_tracks.length==index){
        skipNext();
      }else {
        play("track", _tracks[index].id,
            _tracks[index].name,
            _tracks[index].artists[0].name, _tracks,
            index);
      }
    }
    else {
      skipNext();
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
      setState(() {
        _isPlaylistPlaying = false;
        _isNextSongApiCallCompleted=false;
      });
    } on PlatformException catch (e) {
      _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
      setState(() {
        _isPlaylistPlaying = true;
      });
    } on PlatformException catch (e) {
      _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }

  Future<void> skipNext() async {
    try {
      setState(() {
        _timer.cancel();
        startTimer();
        _currentSongTimeDuration=0;
        _isPlaylistPlaying=true;
        _isNextSongApiCallCompleted=false;
      });
      await SpotifySdk.skipNext();
      if(!_isFromSearch) {
        _fetchCurrentSongsTimeDuration(_tracks[_currentIndexPlayed].name,
            _tracks[_currentIndexPlayed].artists[0].toString());
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
      if(_currentIndexPlayed>=0) {
        setState(() {
          startTimer();
          if(!_isFromSearch) {
            _fetchCurrentSongsTimeDuration(
                _tracks[_currentIndexPlayed - 1].name,
                _tracks[_currentIndexPlayed - 1].artists[0].toString());
          }
        });
      }
    } on PlatformException catch (e) {
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Tracks"),
        actions: [
          FlutterSwitch(
            width: 80.0,
            height: 25.0,
            valueFontSize: 16.0,
            toggleSize: 20.0,
            activeColor: Colors.blue.shade800,
            value: isSwitchEnabled,
            borderRadius: 30.0,
            padding: 0.0,
            showOnOff: true,
            onToggle: (val) {
              setState(() {
                isSwitchEnabled = val;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: ()=>skipPrevious(),
                    )),
                Expanded(
                    child: IconButton(
                      icon: Icon(
                          _isPlaylistPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _isPlaylistPlaying ? pause : resume,
                    )),
                Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: (){
                        _isFromSearch ?skipNext():
                        check();
                      }
                    ))
              ],
            ),
            StreamBuilder<PlayerState>(
                stream: SpotifySdk.subscribePlayerState(),
                builder: (BuildContext context,
                    AsyncSnapshot<PlayerState> snapshot) {
                  var track = snapshot.data?.track;
                  var playerState = snapshot.data;
                  if (playerState == null || track == null) {
                    return Center(
                      child: Container(),
                    );
                  }
                  _fetchCurrentSongsTimeDuration(track.name, track.artists[0].name);
                  return Text(track.name);
                })
          ],
        ),
      ),
      body: ListView(
        children:[

         BlocBuilder<PlayerTracksBloc, PlayerTrackState>(
            builder: (context, state) {

              if (state is PlayerTracksSuccess) {
                return ListView.builder(
                    shrinkWrap:true,itemCount:state.tracks.length,itemBuilder: (context,index){
                  Track track=state.tracks[index];
                  return ListTile(
                    onTap: (){
                      setState(() {
                        _isFromSearch=false;
                      });
                      play("track", track.id,track.name,track.artists[0].name.toString(),state.tracks,index);
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(track.albumImageUrl),
                    ),
                    title: Text(track.name,style: TextStyle(color: Colors.white),)
                  );
                });
              }

              return Container();
            })],
      ),
    );
    /*return MultiBlocListener(
      listeners: [
        BlocListener<PlayerTracksBloc, PlayerTrackState>(
            listenWhen: (previous, current) {
              if (previous is PlayerTracksSuccess &&
                  current is PlayerTracksSuccess) {
                bool isPlayable =
                    !previous.isAllDataLoaded && current.isAllDataLoaded;
                return isPlayable;
              }
              return false;
            }, listener: (context, state) {
          if (state is PlayerTracksSuccess && state.isAllDataLoaded) {
            _currentPlaybackBloc.add(CurrentPlaybackTrackChanged());
          }
        }),
        BlocListener<CurrentPlaybackBloc, CurrentPlaybackState>(
          listenWhen: (previous, current) {
            if (previous is CurrentPlaybackSuccess &&
                current is CurrentPlaybackSuccess) {
              return previous.playback.trackId != current.playback.trackId;
            }
            if ((previous is CurrentPlaybackEmpty ||
                previous is CurrentPlaybackInitial) &&
                current is CurrentPlaybackSuccess) {
              return true;
            }
            return false;
          },
          listener: (context, state) {

            final playerTracksState = _playerTracksBloc.state;
            if (state is CurrentPlaybackSuccess &&
                playerTracksState is PlayerTracksSuccess) {
              final index = playerTracksState.tracks
                  .indexWhere((track) => track.id == state.playback.trackId);
              if (index > -1)
                _carouselController.animateToPage(index,
                    duration: Constants.carouselAnimationDuration);
            }
          },
        )
      ],
      child: BlocBuilder<PlayerTracksBloc, PlayerTrackState>(
          builder: (context, state) {

            if (state is PlayerTracksSuccess) {
              return Stack(
                children: [
                  Image.network(
                    state.currentTrack.albumImageUrl,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
                    child: Scaffold(
                      extendBodyBehindAppBar: true,
                      backgroundColor: Colors.transparent,
                      appBar: PlayerPageAppBar(
                          playlist: state.playlist,
                          isOpenedFromDeepLink: widget.isOpenedFromDeepLink),
                      body: _buildContent(state),
                    ),
                  )
                ],
              );
            }

            return Container();
          }),
    );

     */
  }

  /*Widget _buildContent(PlayerTracksSuccess state) {
    final playlist = state.playlist;
    final currentTrack = state.currentTrack;
    final artistImageUrl = state.currentTrackArtistImageUrl;
    final tracks = state.tracks;
    final storyText = state.storyText ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          PlayerTrackInfo(
            storyText: storyText,
            artistImageUrl: artistImageUrl,
            currentTrack: currentTrack,
            controller: _controller,
          ),
          BlocBuilder<CurrentPlaybackBloc, CurrentPlaybackState>(
              builder: (context, state) {
                var _isPlaying = false;
                if (state is CurrentPlaybackSuccess)
                  _isPlaying = state.playback.isPlaying &&
                      state.playback.playlistId == playlist.id;

                return Column(children: [
                  Column(children: [
                    SizedBox(
                      height: 8.0,
                    ),

                    SizedBox(
                      height: 16.0,
                    )
                  ]),
                  _buildProgressBar(state, currentTrack),
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          color: Colors.white10,
                        ),
                      ),
                      PlayerCarousel(
                          tracks: tracks,
                          onPageChanged: _handleTrackChanged,
                          carouselController: _carouselController,
                          onPlayButtonTap: _onPlayButtonTapped),
                      IgnorePointer(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5,
                          height: MediaQuery.of(context).size.width / 5,
                          padding: EdgeInsets.all(6.0),
                          decoration: new BoxDecoration(
                            color: Colors.black54,
                          ),
                          child: PlayerPlayButton(
                            isPlaying: _isPlaying,
                          ),
                        ),
                      )
                    ],
                  )
                ]);
              }),
        ],
      ),
    );
  }

  _buildProgressBar(CurrentPlaybackState state, Track currentTrack) {
    if (state is CurrentPlaybackSuccess &&
        state.playback.trackId == currentTrack.id) {
      final currentPosition = state.playback.progressMs.toDouble();
      final totalDuration = currentTrack.durationMs.toDouble();
      if (currentPosition > totalDuration)
        return PlaceHolderPlayerProgressBar();
      return LinearProgressIndicator(
        value: currentPosition / totalDuration,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        backgroundColor: Colors.white38,
      );
    }
    return PlaceHolderPlayerProgressBar();
  }
}

class PlaceHolderPlayerProgressBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: 0.0,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      backgroundColor: Colors.white38,
    );
  }
}

class PlayerPageLoading extends StatelessWidget {
  final Playlist playlist;

  const PlayerPageLoading({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PlayerPageAppBar(playlist: playlist),
      body: Center(
        child: StatusIndicator(
          message: 'Loading Tracks',
          status: Status.loading,
        ),
      ),
    );
  }
}


class PlayerPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlayerPageAppBar(
      {required this.playlist, this.isOpenedFromDeepLink = false});
  final Playlist playlist;
  final bool isOpenedFromDeepLink;

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Text(
        playlist.name,
        style: TextStyles.appBarTitle.copyWith(letterSpacing: 0),
      ),
      leading: isOpenedFromDeepLink
          ? IconButton(
            icon:Icon(Icons.arrow_back),
            color: CustomColors.secondaryTextColor,

          onPressed: () => (){

          })
          : null,
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: CustomColors.secondaryTextColor,
      ),

    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


class PlayerPageError extends StatelessWidget {
  final Playlist playlist;

  const PlayerPageError({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PlayerPageAppBar(playlist: playlist),
      body: Center(
        child: StatusIndicator(
          message: 'Failed to load tracks',
          status: Status.error,
        ),
      ),
    );
  }

   */
}