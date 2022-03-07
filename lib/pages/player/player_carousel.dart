import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:spotify_2/shared/constants/values.dart' as Constants;
import 'package:spotify_2/shared/models/tracks.dart';

class PlayerCarousel extends StatefulWidget {
  const PlayerCarousel(
      {
      required this.tracks,
      required this.onPageChanged,
      required this.onPlayButtonTap,
      required this.carouselController})
      ;
  final List<Track> tracks;
  final Function(int index) onPageChanged;
  final Function() onPlayButtonTap;
  final CarouselController carouselController;

  @override
  _PlayerCarouselState createState() => _PlayerCarouselState();
}

class _PlayerCarouselState extends State<PlayerCarousel> {
  int _selectedTrackIndex = 0;

  Future<void> _onTrackTapped(Track tappedtrack) async {
    final indexToNavigate =
        widget.tracks.indexWhere((track) => track.id == tappedtrack.id);
    final trackOffset = indexToNavigate - _selectedTrackIndex;

    if (trackOffset == 0) {
      widget.onPlayButtonTap?.call();
      return;
    }

    await Repeater.repeat(
        callback: trackOffset > 0
            ? () => widget.carouselController
                .nextPage(duration: Constants.carouselAnimationDuration)
            : () => widget.carouselController
                .previousPage(duration: Constants.carouselAnimationDuration),
        repeatNumber: (trackOffset).abs(),
        repeatDuration: Constants.carouselAnimationDuration);
  }

  void _handlePageChange(int index, CarouselPageChangedReason reason) {
    setState(() {
      _selectedTrackIndex = index;
    });
    widget.onPageChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: widget.carouselController,
      options: CarouselOptions(
        aspectRatio: 5 / 1,
        viewportFraction: 0.20,
        enableInfiniteScroll: false,
        onPageChanged: _handlePageChange,
      ),
      items: widget.tracks.map((track) {
        return GestureDetector(
          onTap: () => _onTrackTapped(track),
          child: Image.network(track.albumImageUrl, fit: BoxFit.fill),
        );
      }).toList(),
    );
  }
}

class Repeater {
  static Future<void> repeat(
      {required VoidCallback callback,
        required int repeatNumber,
        Duration repeatDuration = const Duration(milliseconds: 300)}) async {
    for (int i = 0; i < repeatNumber - 1; i++) {
      callback();
      await Future.delayed(repeatDuration);
    }
    callback();
  }
}
