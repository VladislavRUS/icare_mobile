import 'package:flutter/material.dart';
import 'package:flutter_hack/constants/app_colors.dart';
import 'package:flutter_hack/screens/profile.dart';

import 'appointments.dart';

class AppScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppScreenState();
  }
}

class AppScreenState extends State<AppScreen> {
  int screenIndex = 0;
  List<Widget> screens = [ProfileScreen(), AppointmentsScreen()];

  Widget bottomBarButton(
      IconData iconData, String text, Function onTap, bool active) {
    return Expanded(
      flex: 1,
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                color: active
                    ? AppColors.MAIN_COLOR
                    : Color.fromARGB(255, 118, 127, 157),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 10,
                  color: active
                      ? AppColors.MAIN_COLOR
                      : Color.fromARGB(255, 118, 127, 157),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          bottomBarButton(Icons.person, 'Профиль', () => setScreenIndex(0),
              isActiveScreen(0)),
          bottomBarButton(Icons.message, 'Записи', () => setScreenIndex(1),
              isActiveScreen(1)),
          bottomBarButton(Icons.notifications, 'Уведомления',
              () => setScreenIndex(2), isActiveScreen(2)),
          bottomBarButton(Icons.settings, 'Настройки', () => setScreenIndex(3),
              isActiveScreen(3)),
        ]);
  }

  setScreenIndex(int idx) {
    if (idx != 0 && idx != 1) {
      return;
    }

    setState(() {
      screenIndex = idx;
    });
  }

  isActiveScreen(int idx) {
    return screenIndex == idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[screenIndex],
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: Color.fromARGB(0, 0, 0, 0)))),
          child: getRow(),
        ),
      ),
    );
  }
}
