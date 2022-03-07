import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:spotify_2/shared/models/tracks.dart';
import 'dart:convert';
import 'package:sprintf/sprintf.dart';
import 'package:spotify_2/pages/playlist/model/playlist.dart';
class PlayerTrackRepository {
  Dio dio;
  PlayerTrackRepository({required this.dio});

  final String FETCH_PLAYLIST_TRACKS_URL=
      "https://api.spotify.com/v1/playlists/%s/tracks?fields=items(track(id,name,artists,duration_ms,album(images)))";
  // ignore: non_constant_identifier_names
  final String FETCH_SEARCH_TRACKS_URL=
      "https://api.spotify.com/v1/search?q=";

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
      }
    } on DioError catch (e) {
      //print(e.message);
      return false;
    }
  }

  Future<dynamic> fetchTracks(String authToken,String playListId) async {
    Response response;
    try {
      response = await dio.get(sprintf(FETCH_PLAYLIST_TRACKS_URL,[playListId]),
          options:Options(
              headers:{
                "authorization":"Bearer $authToken"
              }
          ));
      if (response.statusCode == 200) {
        List items = response.data['items'];
        return items.map((item) => Track.fromJson(item["track"])).toList();
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