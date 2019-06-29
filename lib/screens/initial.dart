import 'package:flutter/material.dart';
import 'package:flutter_hack/components/loader.dart';
import 'package:flutter_hack/constants/routes.dart';

class InitialScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InitialScreenState();
  }
}

class InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 0), () {
      Navigator.pushReplacementNamed(context, Routes.LOGIN);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: Center(child: Loader()));
  }
}
