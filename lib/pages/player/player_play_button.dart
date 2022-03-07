import 'package:flutter/material.dart';
import 'package:spotify_2/shared/constants/style.dart';

class PlayerPlayButton extends StatelessWidget {
  final bool isPlaying;

  const PlayerPlayButton({ required this.isPlaying}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        size: 40.0,
        color: CustomColors.primaryTextColor,
      ),
      decoration: BoxDecoration(shape: BoxShape.circle),
    );
  }
}
