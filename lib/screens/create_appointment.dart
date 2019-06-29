import 'package:flutter/material.dart';
import 'package:flutter_hack/components/app_bar_text.dart';
import 'package:flutter_hack/components/big_button.dart';
import 'package:flutter_hack/components/input.dart';
import 'package:flutter_hack/components/loader.dart';
import 'package:flutter_hack/constants/app_colors.dart';
import 'package:flutter_hack/constants/durations.dart';
import 'package:flutter_hack/constants/routes.dart';
import 'package:flutter_hack/main.dart';
import 'package:flutter_hack/models/appointment.dart';
import 'package:flutter_hack/models/doctor.dart';
import 'package:flutter_hack/models/specialization.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

import '../store.dart';

class CreateAppointmentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateAppointmentScreenState();
  }
}

class CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  bool isLoading = false;
  bool isInitialized = false;
  TextEditingController dateController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await Future.delayed(Duration(seconds: 1), () async {
      await fetchDoctors();
    });
  }

  fetchDoctors() async {
    Store store = ScopedModel.of<Store>(context);

    try {
      await store.fetchSpecializations();
      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print(e);
    }
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

  Widget buildSpecializationsDropdown() {
    Store store = ScopedModel.of<Store>(context);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Направление', style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<String>(
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down),
              hint: Text('Выберите направление'),
              value: store.selectedSpecialization != null
                  ? store.selectedSpecialization.title
                  : null,
              items: store.specializations.map((Specialization specialization) {
                return new DropdownMenuItem<String>(
                  value: specialization.title,
                  child: new Text(specialization.title),
                );
              }).toList(),
              onChanged: (selectedValue) {
                var specialization =
                    store.specializations.firstWhere((specialization) {
                  return specialization.title == selectedValue;
                });

                store.onSpecializationSelect(specialization);
              }),
        ],
      ),
    );
  }

  Widget buildDoctorsDropdown() {
    Store store = ScopedModel.of<Store>(context);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Врач', style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<String>(
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down),
              hint: Text('Выберите врача'),
              value: store.selectedDoctor != null
                  ? store.selectedDoctor.fullName
                  : null,
              items: store.doctors.map((Doctor doctor) {
                return new DropdownMenuItem<String>(
                  value: doctor.fullName,
                  child: new Text(doctor.fullName),
                );
              }).toList(),
              onChanged: (selectedValue) {
                var doctor = store.doctors.firstWhere((doctor) {
                  return doctor.fullName == selectedValue;
                });

                store.onDoctorSelect(doctor);
              }),
        ],
      ),
    );
  }

  Widget buildCalendar() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Дата', style: TextStyle(fontWeight: FontWeight.w500)),
          InkWell(
            onTap: openDatePicker,
            child: TextFormField(
              enabled: false,
              controller: dateController,
              decoration: InputDecoration(hintText: 'Выберите дату'),
            ),
          )
        ],
      ),
    );
  }

  openDatePicker() async {
    Store store = ScopedModel.of<Store>(context);

    if (store.selectedSpecialization == null || store.selectedDoctor == null) {
      return;
    }

    DateTime now = DateTime.now();
    Duration year = Duration(days: 365);
    DateTime lastDate = now.add(year);
    DateTime firstDate = now;
    DateTime initialDate = firstDate;
    DateTime date = await showDatePicker(
        locale: Locale('ru'),
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);

    if (date != null) {
      dateController.text = DateFormat('dd-MM-yyyy').format(date);
      setState(() {});
    }
  }

  Widget buildTimeSlots() {
    Store store = ScopedModel.of<Store>(context);

    if (dateController.text == '') {
      return null;
    }

    List<Widget> slots = store.timeSlots.map((slot) {
      var isSelected =
          store.selectedTimeSlot != '' && store.selectedTimeSlot == slot;

      return Opacity(
        opacity: isSelected ? 1 : 0.5,
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Material(
            color: AppColors.MAIN_COLOR,
            child: InkWell(
              onTap: () {
                store.onTimeSlotSelect(slot);
              },
              child: Container(
                width: 100,
                height: 40,
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 15),
              child:
                  Text('Время', style: TextStyle(fontWeight: FontWeight.w500))),
          Wrap(
            spacing: 10,
            children: slots,
            alignment: WrapAlignment.spaceAround,
          ),
        ],
      ),
    );
  }

  onCreateAppointment() async {
    Store store = ScopedModel.of<Store>(context);

    if (store.selectedSpecialization == null ||
        store.selectedDoctor == null ||
        dateController.text == '' ||
        store.selectedTimeSlot == '') {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Заполните все поля'),
              ));

      return;
    }

    Appointment appointment = new Appointment();
    appointment.doctor = store.selectedDoctor;
    List<String> splitDate = dateController.text.split('-');
    List<String> splitTime = store.selectedTimeSlot.split(':');
    DateTime date = DateTime(
        int.parse(splitDate[2]),
        int.parse(splitDate[1]),
        int.parse(splitDate[0]),
        int.parse(splitTime[0]),
        int.parse(splitTime[1]));
    appointment.dateTimestamp = date.millisecondsSinceEpoch.toString();
    appointment.user = store.currentUser;

    showLoader();

    await Future.delayed(Duration(milliseconds: Durations.REQUEST_DELAY_MS));

    try {
      Appointment createdAppointment =
          await store.createAppointment(appointment);

      Future.delayed(Duration(seconds: 2), () {
        String title = 'Подтвердите запись на прием';
        String body =
            '${createdAppointment.doctor.fullName}, ${createdAppointment.doctor.specialization.title}';

        store.sendPush(title, body, createdAppointment.id.toString(),
            (String payload) {
          print(payload);
          store.onAppointmentSelect(createdAppointment);
          navigatorKey.currentState.pushNamed(Routes.DETAILED_APPOINTMENT);
        });
      });

      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    } finally {
      hideLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScopedModel.of<Store>(context, rebuildOnChange: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.clear,
              color: AppColors.HEADER_TEXT_COLOR,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        elevation: 1,
        backgroundColor: Colors.white,
        title: AppBarText(text: 'Новая запись'),
      ),
      backgroundColor: AppColors.BACKGROUND_COLOR,
      body: Center(
        child: !isInitialized
            ? Loader()
            : Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    buildSpecializationsDropdown(),
                    buildDoctorsDropdown(),
                    buildCalendar(),
                    buildTimeSlots(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          BigButton(
                            text: 'Записаться',
                            onTap: onCreateAppointment,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    )
                  ].where((element) => element != null).toList(),
                )),
      ),
    );
  }
}
