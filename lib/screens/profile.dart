import 'package:flutter/material.dart';
import 'package:flutter_hack/components/app_bar_text.dart';
import 'package:flutter_hack/components/input.dart';
import 'package:flutter_hack/constants/app_colors.dart';
import 'package:flutter_hack/constants/routes.dart';
import 'package:flutter_hack/models/user.dart';
import 'package:scoped_model/scoped_model.dart';

import '../store.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  Widget buildInfo() {
    Store store = ScopedModel.of<Store>(context);

    User user = store.currentUser;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildInfoItem('Имя', user.firstName),
          buildInfoItem('Фамилия', user.lastName),
          buildInfoItem('Отчество', user.patronymic),
          buildInfoItem('Дата рождения',
              '23-07-${(DateTime.now().year - user.age).toString()}'),
          buildInfoItem('Паспорт, серия', '4353'),
          buildInfoItem('Паспорт, номер', '835451'),
          buildInfoItem('Полис ОМС', '5562333564'),
        ],
      ),
    );
  }

  Widget buildInfoItem(String key, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              key,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          Input(
            isEnabled: false,
            controller: TextEditingController(text: value),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BACKGROUND_COLOR,
      appBar: AppBar(
        elevation: 0.3,
        backgroundColor: Colors.white,
        title: AppBarText(text: 'Профиль'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [buildInfo()],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
