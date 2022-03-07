import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_2/app.dart';

Future main() async {
  runApp(spotify_app());
}

class spotify_app extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}
