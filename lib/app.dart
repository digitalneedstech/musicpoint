import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spotify_2/pages/home_page/home_page.dart';
import 'package:spotify_2/pages/onboarding_page/onboarding_page.dart';
import 'package:spotify_2/pages/sign_in_page/sign_in_page.dart';
import 'package:spotify_2/pages/splash_page/splash_page.dart';
import 'package:spotify_2/shared/constants/style.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:uni_links/uni_links.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'spotify_app',
        themeMode: ThemeMode.dark,
        initialRoute: SplashPage.routeName,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF091227),
          cursorColor: Colors.green[700],
          textSelectionColor: Colors.green[100]!.withOpacity(0.1),
          textSelectionHandleColor: Colors.green[700],
          textTheme: Theme.of(context).textTheme.apply(
            fontFamily: 'Montserrat',
              displayColor: Colors.white70,
              bodyColor: CustomColors.secondaryTextColor),
        ),
        navigatorObservers: [
          BotToastNavigatorObserver()
        ],
        home: StreamBuilder<ConnectionStatus>(
          stream: SpotifySdk.subscribeConnectionStatus(),
          builder: (context, snapshot) {
            var data = snapshot.data;
            if (data != null) {
              print(data.connected);
              return SignInPage();
            }
            return Scaffold();

          },
        ),
        routes: {
          SignInPage.routeName: (context) => SignInPage(),
          HomePage.routeName: (context) => HomePage(),
          OnboardingPage.routeName: (context) => OnboardingPage(),
          SplashPage.routeName: (context) => SplashPage(),
        });
  }
}
