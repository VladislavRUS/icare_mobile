import 'package:flutter/material.dart';
import 'package:flutter_hack/components/big_button.dart';
import 'package:flutter_hack/constants/app_colors.dart';
import 'package:flutter_hack/constants/durations.dart';
import 'package:flutter_hack/constants/routes.dart';
import 'package:scoped_model/scoped_model.dart';

import '../store.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  showLoader() {
    setState(() {
      isLoading = true;
    });
  }

  hideLoader() {
    setState(() {
      isLoading = false;
    });
  }

  Future onPush(String payload) {
    print('asdf');
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(title: Text('hello')));
  }

  onTap() {
    Store store = ScopedModel.of<Store>(context);
  }

  onEnter() async {
    Store store = ScopedModel.of<Store>(context);

    showLoader();

    await Future.delayed(Duration(milliseconds: Durations.REQUEST_DELAY_MS));

    try {
      await store.login();
      Navigator.pushReplacementNamed(context, Routes.APP);
    } catch (e) {
      print(e);
    } finally {
      hideLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BACKGROUND_COLOR,
      body: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -40,
              left: -5,
              child: SizedBox(
                  width: 350,
                  height: 350,
                  child: Image.asset('assets/mobile_combined.png')),
            ),
            Positioned(
              bottom: 250,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: 250,
                      child: Center(
                        child: Image.asset('assets/mobile_logo.png',
                            fit: BoxFit.fitWidth),
                      )),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: BigButton(
                        isLoading: isLoading,
                        text: 'Войти через Госуслуги',
                        onTap: onEnter,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
