import 'package:flutter/material.dart';
import 'package:flutter_hack/components/app_bar_text.dart';
import 'package:flutter_hack/components/big_button.dart';
import 'package:flutter_hack/components/input.dart';
import 'package:flutter_hack/components/loader.dart';
import 'package:flutter_hack/constants/app_colors.dart';
import 'package:flutter_hack/constants/durations.dart';
import 'package:flutter_hack/constants/routes.dart';
import 'package:scoped_model/scoped_model.dart';

import '../main.dart';
import '../store.dart';

class DetailedAppointmentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DetailedAppointmentScreenState();
  }
}

class DetailedAppointmentScreenState extends State<DetailedAppointmentScreen> {
  bool isConfirming = false;

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

  Widget buildInfo() {
    Store store = ScopedModel.of<Store>(context);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildInfoItem('Направление',
              store.detailedAppointment.doctor.specialization.title),
          buildInfoItem('Врач', store.detailedAppointment.doctor.fullName),
          buildInfoItem(
              'Дата и время', store.detailedAppointment.formattedDateTime)
        ],
      ),
    );
  }

  Widget buildConfirmButton() {
    Store store = ScopedModel.of<Store>(context);

    if (store.detailedAppointment.isConfirmedByUser) {
      return null;
    }

    if (store.detailedAppointment.isFinishedByDoctor) {
      return null;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          BigButton(
            text: 'Подтвердить прием',
            onTap: onConfirm,
            isLoading: isConfirming,
          ),
        ],
      ),
    );
  }

  Widget buildPollButton() {
    Store store = ScopedModel.of<Store>(context);

    if (!store.detailedAppointment.isFinishedByDoctor) {
      return null;
    }

    if (store.detailedAppointment.isPollFinishedByUser) {
      return null;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          BigButton(
            text: 'Пройти опрос',
            onTap: () {
              Navigator.of(context).pushNamed(Routes.QUESTIONS);
            },
            isLoading: false,
          ),
        ],
      ),
    );
  }

  onConfirm() async {
    Store store = ScopedModel.of<Store>(context);

    setState(() {
      isConfirming = true;
    });

    await Future.delayed(Duration(milliseconds: Durations.REQUEST_DELAY_MS));

    try {
      await store.confirm();

      Future.delayed(Duration(seconds: 2), () async {
        String title = 'Пройдите опрос по приему';
        var appointment = store.detailedAppointment;

        String body = 'Опрос поможет улучшить качество облсуживания';

        store.sendPush(title, body, appointment.id.toString(),
            (String payload) async {
          store.onAppointmentSelect(appointment);
          navigatorKey.currentState.pushNamed(Routes.QUESTIONS);
        });
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScopedModel.of<Store>(context, rebuildOnChange: true);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.HEADER_TEXT_COLOR,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          elevation: 1,
          backgroundColor: Colors.white,
          title: AppBarText(text: 'Детали приема'),
        ),
        body: Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildInfo(),
                buildConfirmButton(),
                buildPollButton()
              ].where((widget) => widget != null).toList(),
            )));
  }
}
