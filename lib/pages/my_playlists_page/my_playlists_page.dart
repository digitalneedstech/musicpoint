import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_2/pages/player/bloc/player_track_bloc.dart';
import 'package:spotify_2/pages/player/index.dart';
import 'package:spotify_2/pages/player/songs_list.dart';
import 'package:spotify_2/pages/player/status_indicator.dart';
import 'package:spotify_2/pages/playlist/bloc/playlist_bloc.dart';
import 'package:spotify_2/pages/playlist/bloc/playlist_event.dart';
import 'package:spotify_2/pages/playlist/bloc/playlist_state.dart';
import 'package:spotify_2/pages/playlist/repos/playlist_repo.dart';
import 'package:spotify_2/shared/models/tracks.dart';
import 'package:spotify_2/shared/widgets/overlay_model/custom_rounded_button.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MyPlaylistsPage extends StatefulWidget {
  final Function playlistPlayCallback;
  final Function playlistLoadedCallback;
  MyPlaylistsPage({required this.playlistPlayCallback,required this.playlistLoadedCallback});
  static Widget create(Function callback,Function playlistLoadedCallback) {
    return BlocProvider(
      create: (_) => PlaylistBloc(playlistRepository: new PlaylistRepository(dio: Dio()))
        ..add(PlaylistFetched()),
      child: MyPlaylistsPage(playlistPlayCallback: callback,playlistLoadedCallback: playlistLoadedCallback),
    );
  }
  @override
  _MyPlaylistsPageState createState() => _MyPlaylistsPageState();
}

class _MyPlaylistsPageState extends State<MyPlaylistsPage> {
  bool _isPlaylistPlaying=false;

  int _currentSongTimeDuration=0;

  late Timer _timer;

  bool _isNextSongApiCallCompleted=false;

  @override
  void initState(){
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        switch (state.status) {
          case PlaylistStatus.failure:
            return const StatusIndicator(
                status: Status.error,
                message:"There was an error while fetching playlist");
          case PlaylistStatus.success:
            final playlists = state.playlist;
            return Column(
              children: [
                Expanded(child: Container(
                  child: Center(child: Image.asset(
                    'images/music_point.jpeg',

                  ),),
                )),

                Expanded(
                  child: ListView(
                    children:[ CarouselSlider(
                      options: CarouselOptions
                        (
                        autoPlay: true,
                        enlargeCenterPage: true,
                        //height: 300.0,
                        //viewportFraction: 1.0
                        /*height: 200.0,
                        enlargeCenterPage: true,

                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        viewportFraction: 1.0*/
                      ),
                      items: playlists.map((i) {
                        return InkWell(
                              onTap: (){
                                widget.playlistPlayCallback("playlist",i.id);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PlayerPage.create(playlist: i,callback: (String type,String id){
                                              widget.playlistPlayCallback("playlist",i.id);
                                            })));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height:100.0,
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.all(20.0),
                                    child: Image.network(i.playlistImageUrl,fit: BoxFit.cover,),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),

                                    ),

                                  ),
                                  Text(i.name,style: const TextStyle(color: Colors.white))
                                ],
                              ),
                            );
                          },
                        ).toList(),
                    )]
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomRoundedButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SongsList.create(callback: (Track track){
                                    playFromSearch("track", track.id, track.name,track.artists[0].name);
                                  })));
                    },
                    borderColor: Colors.green,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    buttonText: 'Start With A Song',
                  ),
                ),
                const Expanded(child: SizedBox()),
                Column(
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
                                  skipNext();
                                }
                            ))
                      ],
                    )
                  ],
                )
                //const Expanded(child: SizedBox()),

              ],
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer time) {
        if(_currentSongTimeDuration!=0 && _timer.tick>=_currentSongTimeDuration) {
          skipNext();
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
        _isPlaylistPlaying = true;
        _currentSongTimeDuration=0;
        _isNextSongApiCallCompleted=false;
      });
      _fetchCurrentSongsTimeDuration(title, artist);
    } on PlatformException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      print("hi");
      //setStatus('not implemented');
    }
  }

  void _fetchCurrentSongsTimeDuration(String title, String artist) {
    fetchTimeDurationUntillCurrentTrackIsPlayed(title, artist)
        .then((value) {
      if (value is String) {
        String timestamp = value;
        int totalSeconds = int.parse(
            timestamp.split(":")[0]) * 60 +
            int.parse(
                (timestamp.split(":")[1]).split(".")[0]);
        if(totalSeconds==0){
          skipNext();

        }else {
          setState(() {
            _currentSongTimeDuration = totalSeconds;
            _isNextSongApiCallCompleted=true;
          });
        }
      }
      else if(value is bool){
        skipNext();
      }
    });
  }

  Future<dynamic> fetchTimeDurationUntillCurrentTrackIsPlayed(String name,String artist) async {
    Response response;
    try {
      response = await Dio().post("https://music.dualite.xyz/api/v1/predict/",
          data: {
            "title":name,
            "artist":artist
          });
      if (response.statusCode == 200) {
        //TODO- UPDATE THE RESPONSE
        return response.data["timestamp"];
      }
    } on DioError catch (e) {
      //print(e.message);
      return false;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
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

    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
      setState(() {
          startTimer();
        });

    } on PlatformException catch (e) {
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }
}
