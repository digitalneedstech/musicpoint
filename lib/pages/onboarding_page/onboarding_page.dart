import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_2/pages/sign_in_page/sign_in_page.dart';
import 'package:spotify_2/shared/constants/style.dart';

import 'custom_page_view_model.dart';

class OnboardingPage extends StatelessWidget {
  static const routeName = '/onboarding';

  final List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: 'Don’t stop me now.',
      body:
      'Let the music go on without you continously changing or looking for the next song.',
      image: Image.asset('assets/images/music_point.jpeg', width: 350),
    ),
    PageViewModel(
      title: 'Don’t stop me now.',
      body:
      'Login automatically through Spotify and let us do the heavylifting of changing your playlist just at the right time, while you keep on enjoying!',
      image: Image.asset('assets/images/music_point.jpeg', width: 350),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPagesViewModel,
      next: Text(
        "Next",
        style: TextStyles.primary.copyWith(fontSize: 16.0),
      ),
      done: Text(
        "Done",
        style: TextStyles.primary.copyWith(fontSize: 16.0),
      ),
      dotsDecorator: DotsDecorator(
          activeColor: Colors.green,
          color: Colors.white38,
          size: Size.square(6.0)),
      onDone: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('seen', true);
        Navigator.of(context).popAndPushNamed(SignInPage.routeName);
      },
    );
  }
}
