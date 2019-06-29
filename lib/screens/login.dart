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
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/mobile_bg.png'), fit: BoxFit.cover)),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 220,
              right: 50,
              child: Container(
                  width: 130,
                  height: 130,
                  child: Image.asset('assets/mobile_s.png')),
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
              left: 0,
              right: 0,
              bottom: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: BigButton(
                      isLoading: isLoading,
                      text: 'Войти через Госуслуги',
                      onTap: onEnter,
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
