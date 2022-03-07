import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_2/pages/home_page/home_page.dart';
import 'package:spotify_2/shared/constants/style.dart';
import 'package:spotify_2/shared/widgets/custom_toast/custom_toast.dart';
import 'package:spotify_2/shared/widgets/overlay_model/custom_rounded_button.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SignInPage extends StatefulWidget {
  static const routeName = '/sign_in';


  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isLoading = false;
  Future<void> _handleSignIn(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      await getAuthenticationToken();
      Navigator.popAndPushNamed(context, HomePage.routeName);
    } catch (e) {
      CustomToast.showTextToast(
          text: "Failed to sign in", toastType: ToastType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: "cbfc453972ee48fcb6a15c6ea7efd82d",
          redirectUrl: "http://localhost:8000/spotify_login",
          //clientId: "d11a35808a5f46429feddbd4ad171e0c",
          //redirectUrl:"https://localhost:8080/test",
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      SharedPreferences preferences=await SharedPreferences.getInstance();
      preferences.setString("auth", authenticationToken);

    } on PlatformException catch (e) {
      //setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      //setStatus('not implemented');
      return Future.error('not implemented');
    }
  }
  bool _isConnected=false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
          extendBodyBehindAppBar: true,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Image.asset(
                      'images/music_point.jpeg',
                      width: 280.0,
                    )
                  ],
                ),
                _isLoading
                    ? const SpinKitFadingCube(
                    size: 36, color: CustomColors.secondaryTextColor)
                    : CustomRoundedButton(
                  onPressed: () => _handleSignIn(context),
                  borderColor: Colors.green,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  buttonText: 'SIGN IN WITH SPOTIFY',
                )
              ],
            ),
          ),
        );
  }
}
