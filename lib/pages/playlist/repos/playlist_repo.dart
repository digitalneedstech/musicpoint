import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:spotify_2/pages/playlist/model/playlist.dart';
import 'package:spotify_2/shared/models/tracks.dart';
class PlaylistRepository {
  Dio dio;
  PlaylistRepository({required this.dio});
  final String FETCH_SEARCH_TRACKS_URL=
      "https://api.spotify.com/v1/search?q=";
  final String FETCH_PLAYLIST_URL="https://api.spotify.com/v1/me/playlists?limit=10&offset=0";

  final String PREDICT_API=
      "https://music.dualite.xyz/api/v1/predict/";

  Future<dynamic> fetchTimeDurationUntillCurrentTrackIsPlayed(String name,String artist) async {
    Response response;
    try {
      response = await dio.post(PREDICT_API,
          data: {
            "title":name,
            "artist":artist
          });
      if (response.statusCode == 200) {
        //TODO- UPDATE THE RESPONSE
        return response.data["timestamp"];
      } else {
        return false;
      }
    } on DioError catch (e) {
      //print(e.message);
      return false;
    }
  }

  Future<dynamic> fetchPlayList(String authToken) async {
    Response response;
    try {
      response = await dio.get(FETCH_PLAYLIST_URL,
          options:Options(
            headers:{
              "Authorization":"Bearer $authToken"
            }
          ));
      if (response.statusCode == 200) {
        List items = response.data['items'];
        List<Playlist> playlists= items.map((item) => Playlist.fromJson(item)).toList();
        return playlists;
      } else {
        throw Exception(
            'Failed to get list of playlists with status code ${response.statusCode}');
      }
    } on DioError catch (e) {
      //print(e.message);
      return "There was an error";
    }
  }


  Future<dynamic> fetchSearchTracks(String authToken,String query) async {
    Response response;
    try {
      String url=FETCH_SEARCH_TRACKS_URL+query+"&type=track";
      response = await dio.get(url,
          options:Options(
              headers:{
                "Authorization":"Bearer $authToken"
              }
          ));
      print("statusCode:"+response.statusCode.toString());
      if (response.statusCode == 200) {
        List items = response.data['tracks']['items'];
        return items.map((item) => Track.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to get list of playlists with status code ${response.statusCode}');
      }
    } on DioError catch (e) {
      print(e.message);
      return "There was an error";
    }
  }

}