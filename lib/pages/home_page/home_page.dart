import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_2/pages/my_playlists_page/my_playlists_page.dart';
import 'package:spotify_2/pages/playlist/bloc/playlist_bloc.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/pages/playlist/repos/playlist_repo.dart';
import 'package:spotify_2/pages/playlist/bloc/playlist_event.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPlaylistPlaying = false;
  late Timer _timer;

  late int _currentSongId;
  late String _currentPlayingPlaylist;
  late List<Playlist> playList;
  late Map<String,int> playlistWithSongsCount;

  bool _isLoading = false;

  bool isPlaying=false;

  @override
  void initState() {
    super.initState();
    connectToSpotifyRemote();
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await SpotifySdk.connectToSpotifyRemote(
          clientId: "cbfc453972ee48fcb6a15c6ea7efd82d",
          redirectUrl: "http://localhost:8000/spotify_login");
          //clientId: "37180d382b3a4dd7bb97791d6246cb1f",
          //redirectUrl:"http://localhost:8088/test");
      setState(() {
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
    } on MissingPluginException {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void startTimer(int start,int limit) {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if(timer.tick==limit){
          skipNext();

        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<ConnectionStatus>(

        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (data != null && data.connected) {
            return BlocProvider(
                create: (_) =>
                PlaylistBloc(playlistRepository: PlaylistRepository(dio: Dio()))
                  ..add(PlaylistFetched()),
                child: SafeArea(
                  bottom: false,
                  child: Scaffold(
                    body:
                    MyPlaylistsPage.create((String type, String id) {
                      play(type, id);
                    }, (List<Playlist> playlists) {
                      setState(() {
                        playList = playlists;
                        playlistWithSongsCount = {};
                        for (Playlist playlist in playlists) {
                          playlistWithSongsCount[playlist.id] =
                              playlist.numOfTracks;
                        }
                      });
                    }),
                    /*bottomNavigationBar: Container(
                      color: Color(0xFF091227),
                      height: MediaQuery.of(context).size.height*0.1,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                          child: _isPlaylistPlaying ? IconButton(onPressed: (){
                            pause();
                          },icon: const Icon(Icons.pause,color: Colors.white,),):Container()

                      ),
                    )*/
                    ),
                ),
                );


          }
          else if(data!=null && !data.connected) {
            return const Scaffold(body: Center(child: Text("There was an error from spotify"),),);
          }
          return const Scaffold(body: Center(child: Text("Loading")),);
        });

  }

  Future<void> play(String type, String uri) async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:$type:$uri');
      setState(() {
        _isPlaylistPlaying = true;
        /*_currentPlayingPlaylist=uri;
        _currentSongId=0;*/
      });
    } on PlatformException catch (e) {
      print(e);
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      print("hi");
      //setStatus('not implemented');
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
      setState(() {
        _isPlaylistPlaying = false;
      });
    } on PlatformException catch (e) {
      //setStatus(e.code, message: e.message);
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
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
      setState(() {
        _timer.cancel();
      });
      /*if(playlistWithSongsCount[_currentPlayingPlaylist]!=null) {
        int songs = playlistWithSongsCount[_currentPlayingPlaylist]!;
        if (_currentSongId == (songs - 1)) {

          List<String> nextPlaylist = playlistWithSongsCount.keys.toList();
          int index = nextPlaylist.indexOf(_currentPlayingPlaylist);
          if (index<nextPlaylist.length - 1) {
            await SpotifySdk.skipNext();
            setState(() {
              _currentSongId++;
              _start=0;
              startTimer();
            });
          }

        }
        else{
          await SpotifySdk.skipNext();

        setState(() {
          _currentSongId++;
          _start=0;
          startTimer();
        });
        }
      }
      else{
        List<String> nextPlaylist = playlistWithSongsCount.keys.toList();
        int index = nextPlaylist.indexOf(_currentPlayingPlaylist);
        if (index<nextPlaylist.length - 1) {
          await play("playlist", nextPlaylist[index+1]);
        }

      }*/
    } on PlatformException catch (e) {
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();

      /*if(playlistWithSongsCount[_currentPlayingPlaylist]!=null) {
        int songs = playlistWithSongsCount[_currentPlayingPlaylist]!;
        if (_currentSongId == (songs - 1)) {

          List<String> nextPlaylist = playlistWithSongsCount.keys.toList();
          int index = nextPlaylist.indexOf(_currentPlayingPlaylist);
          if (index>0) {
            await SpotifySdk.skipPrevious();
            setState(() {
              _currentSongId++;
              _start=0;
              startTimer();
            });
          }
        }
        else{
          await SpotifySdk.skipPrevious();

          setState(() {
            _currentSongId++;
            _start=0;
            startTimer();
          });
        }
      }else {
        List<String> nextPlaylist = playlistWithSongsCount.keys.toList();
        int index = nextPlaylist.indexOf(_currentPlayingPlaylist);
        if (index>0) {
          await play("playlist", nextPlaylist[index-1]);
        }
      }*/
    } on PlatformException catch (e) {
      //setStatus(e.code, message: e.message);
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }
}
