import 'package:flutter/material.dart';
import 'package:flutter_hack/components/app_bar_text.dart';
import 'package:flutter_hack/components/loader.dart';
import 'package:flutter_hack/constants/app_colors.dart';
import 'package:flutter_hack/constants/durations.dart';
import 'package:flutter_hack/constants/routes.dart';
import 'package:flutter_hack/models/appointment.dart';
import 'package:scoped_model/scoped_model.dart';

import '../store.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppointmentsScreenState();
  }
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    init();
  }

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

  init() async {
    showLoader();
    await fetchAppointments();
    hideLoader();
  }

  fetchAppointments() async {
    Store store = ScopedModel.of<Store>(context);

    await Future.delayed(Duration(milliseconds: Durations.REQUEST_DELAY_MS));

    try {
      await store.fetchAppointments();
    } catch (e) {
      print(e);
    }
  }

  onCreateAppointment() async {
    await Navigator.of(context).pushNamed(Routes.CREATE_APPOINTMENT);
    init();
  }

  List<Widget> buildList() {
    Store store = ScopedModel.of<Store>(context);

    List<Appointment> activeAppointments = [];
    List<Appointment> finishedAppointments = [];

    store.appointments.forEach((appointment) {
      if (!appointment.isFinishedByDoctor) {
        activeAppointments.add(appointment);
      } else {
        finishedAppointments.add(appointment);
      }
    });

    List<Widget> list = [];
    activeAppointments.forEach((appointment) {
      list.add(buildAppointment(appointment));
    });

    if (finishedAppointments.length > 0) {
      list.add(Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Opacity(
                opacity: 0.7,
                child: Container(
                  margin: EdgeInsets.only(top: 15, bottom: 5),
                  child: Text('Завершенные',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ));
    }

    finishedAppointments.forEach((appointment) {
      list.add(buildAppointment(appointment));
    });

    return list;
  }

  Widget buildAppointment(Appointment appointment) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            onAppointment(appointment);
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Text(appointment.doctor.fullName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ),
                Opacity(
                  opacity: 0.7,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Text(appointment.doctor.specialization.title,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                ),
                Opacity(
                  opacity: 0.7,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text('24 апреля 2019 в 21:00',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w300)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }

  @override
  Widget build(BuildContext context) {
    ScopedModel.of<Store>(context, rebuildOnChange: true);

    return Scaffold(
      backgroundColor: AppColors.BACKGROUND_COLOR,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: AppBarText(text: 'Записи'),
      ),
      body: isLoading
          ? Center(
              child: Loader(),
            )
          : Container(
              padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildList(),
                ),
              )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.MAIN_COLOR,
        onPressed: onCreateAppointment,
        child: Icon(Icons.add),
      ),
    );
  }

  void onAppointment(Appointment appointment) {
    Store store = ScopedModel.of<Store>(context);
    store.onAppointmentSelect(appointment);
    Navigator.of(context).pushNamed(Routes.DETAILED_APPOINTMENT);
  }
}
