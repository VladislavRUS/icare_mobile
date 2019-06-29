import 'package:flutter_hack/models/user.dart';
import 'package:intl/intl.dart';

import 'doctor.dart';

class Appointment {
  int id;
  Doctor doctor;
  User user;
  String dateTimestamp;
  bool isConfirmedByUser;
  bool isFinishedByDoctor;

  get formattedDateTime {
    return DateFormat('dd-MM-yyyy HH:mm').format(
        DateTime.fromMicrosecondsSinceEpoch(int.parse(dateTimestamp) * 1000));
  }

  Appointment();

  Appointment.fromJson(map) {
    id = map['id'];
    doctor = Doctor.fromJson(map['doctor']);
    user = User.fromJson(map['user']);
    dateTimestamp = map['dateTimestamp'];
    isConfirmedByUser = map['isConfirmedByUser'];
    isFinishedByDoctor = map['isFinishedByDoctor'];
  }
}
