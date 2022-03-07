import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spotify_2/shared/constants/style.dart';

class OverlayMenu extends StatelessWidget {
  const OverlayMenu({ required this.menuBody}) ;
  final Widget menuBody;

  static void show(BuildContext context, {required Widget menuBody}) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) =>
          OverlayMenu(menuBody: menuBody),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: 0.0, end: 1.0);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.linear,
        );

        return FadeTransition(
          opacity: tween.animate(curvedAnimation),
          child: child,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: TextStyles.appBarTitle.color,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )),
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
          body: menuBody),
    );
  }
}
