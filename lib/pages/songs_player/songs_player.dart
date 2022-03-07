import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SongsPlayer extends StatefulWidget {
  SongsPlayerState createState() => SongsPlayerState();
}

class SongsPlayerState extends State<SongsPlayer> {
  bool _isPlaylistPlaying = false;

  int _currentSongTimeDuration = 0;

  late Timer _timer;

  bool _isNextSongApiCallCompleted = false;

  Uint8List? image;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_currentSongTimeDuration != 0 &&
            timer.tick >= _currentSongTimeDuration) {
          skipNext();
        }
      },
    );
  }

  @override
  void dispose(){
    _timer.cancel();
    pause();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Scaffold(
            body: StreamBuilder<PlayerState>(
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
                  _fetchCurrentSongsTimeDuration(
                      track.name, track.artists[0].name);
                  _getImageUrl(track.imageUri);
                    return Column(
                      children: [
                        const Expanded(child: SizedBox()),
                        Expanded(flex:2,
                            child:
                            image==null ? Container():Image.memory(image!)),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(track.name,style: const TextStyle(fontSize: 20.0)),
                        )),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => skipPrevious(),
                                  )),
                              Expanded(
                                  child: IconButton(
                                    icon: Icon(_isPlaylistPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                    onPressed: _isPlaylistPlaying ? pause : resume,
                                  )),
                              Expanded(
                                  child: IconButton(
                                      icon: const Icon(Icons.arrow_forward),
                                      onPressed: () {
                                        skipNext();
                                      }))
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox())
                      ],
                    );
                  return Container();
                })));
  }

  void _getImageUrl(ImageUri imageUri)async{
    if(image==null) {
      Uint8List? uint8list = await SpotifySdk.getImage(imageUri: imageUri);
      if (uint8list != null) {
        setState(() {
          image = uint8list;
        });
      }
    }
  }


  void _fetchCurrentSongsTimeDuration(String title, String artist) {
    fetchTimeDurationUntillCurrentTrackIsPlayed(title, artist).then((value) {
      if (value is String) {
        String timestamp = value;
        int totalSeconds = int.parse(timestamp.split(":")[0]) * 60 +
            int.parse((timestamp.split(":")[1]).split(".")[0]);
        if (totalSeconds == 0) {
          skipNext();
        } else {
          setState(() {
            _currentSongTimeDuration = totalSeconds;
            _isNextSongApiCallCompleted = true;
          });
        }
      } else if (value is bool) {
        skipNext();
      }
    });
  }

  Future<dynamic> fetchTimeDurationUntillCurrentTrackIsPlayed(
      String name, String artist) async {
    Response response;
    try {
      response = await Dio().post("https://music.dualite.xyz/api/v1/predict/",
          data: {"title": name, "artist": artist});
      if (response.statusCode == 200) {
        //TODO- UPDATE THE RESPONSE
        return response.data["timestamp"];
      }
    } on DioError catch (e) {
      //print(e.message);
      return false;
    }
  }


  Future<void> skipNext() async {
    try {
      setState(() {
        _timer.cancel();
        startTimer();
        _currentSongTimeDuration = 0;
        _isPlaylistPlaying = true;
        _isNextSongApiCallCompleted = false;
      });
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
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
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
      setState(() {
        _isPlaylistPlaying = false;
        _isNextSongApiCallCompleted = false;
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on MissingPluginException {
      //setStatus('not implemented');
    }
  }
}
