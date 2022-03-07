import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_event.dart';
import 'package:spotify_2/pages/player/bloc/player_tracks_state.dart';
import 'package:spotify_2/pages/player/bloc/search_bloc/search_bloc.dart';
import 'package:spotify_2/pages/player/repos/player_track_repo.dart';
import 'package:spotify_2/pages/songs_player/songs_player.dart';

class SongsList extends StatefulWidget {
  final Function callback;
  SongsList({required this.callback});
  static Widget create({required Function callback}) {
    return BlocProvider(
        create: (_) => SearchBloc(
            playerTrackRepository: PlayerTrackRepository(dio: Dio())
        ),
        child: SongsList(callback: callback)
    );
  }
  SongsListState createState() => SongsListState();
}

class SongsListState extends State<SongsList> {
  final TextEditingController _textEditingController =
      TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextFormField(

                controller: _textEditingController,
                onChanged: (String? val){
                  if(val!=null){
                    BlocProvider.of<SearchBloc>(context).add(
                        FetchSongsForSearchQuery(
                            query: _textEditingController.text));
                  }
                },
                decoration: const InputDecoration(
                  hintText: "Search For A Song"
                    ),
              ),
              Expanded(child: BlocBuilder<SearchBloc, PlayerTrackState>(
                  builder: (context, state) {
                if (state is SearchTracksSuccess) {
                  return ListView.builder(
                      itemCount: state.tracks.length,
                      itemBuilder: (context, int index) {
                    return ListTile(
                      title: Text(state.tracks[index].name),
                      onTap: () async {
                        widget.callback(state.tracks[index]);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SongsPlayer()));
                      },
                    );
                  });
                }
                return Container();
              }))
            ],
          ),
        ),
      ),
    );
  }
}
