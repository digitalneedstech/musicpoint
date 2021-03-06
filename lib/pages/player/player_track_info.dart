import 'package:flutter/material.dart';
import 'package:spotify_2/shared/constants/style.dart';
import 'package:spotify_2/shared/models/artist.dart';
import 'package:spotify_2/shared/models/tracks.dart';
import 'package:spotify_2/shared/widgets/custom_auto_size_text.dart';
import 'package:spotify_2/shared/widgets/custom_image_provider.dart';

class PlayerTrackInfo extends StatelessWidget {
  const PlayerTrackInfo(
      {
      required this.storyText,
      required this.currentTrack,
      required this.artistImageUrl,
      required this.controller})
      ;
  final String storyText;
  final Track currentTrack;
  final String artistImageUrl;
  final ScrollController controller;

  String _artistNames(List<Artist> artists) =>
      artists.map((artist) => artist.name).join(', ');

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 48.0,
            ),
            CircleAvatar(
                radius: 54.0,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    CustomImageProvider.cachedImage(artistImageUrl)),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(children: [
                Text(_artistNames(currentTrack.artists),
                    textAlign: TextAlign.center,
                    style: TextStyles.secondary.copyWith(fontSize: 16.0)),

              ]),
            ),
            SizedBox(
              height: 16.0,
            ),
            if (storyText != '')
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                width: double.infinity,
                child: Text(
                  storyText,
                  textAlign: TextAlign.start,
                  style: TextStyles.secondary
                      .copyWith(fontSize: 18.0, height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
