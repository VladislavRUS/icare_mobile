import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:requests/requests.dart';

import 'models/answer.dart';
import 'models/appointment.dart';
import 'models/doctor.dart';
import 'models/question.dart';
import 'models/specialization.dart';
import 'models/user.dart';

var baseUrl = 'http://10.12.16.175:3000';

class Store extends Model {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  InitializationSettings initializationSettings;
  User currentUser;
  List<Specialization> specializations = [];
  Specialization selectedSpecialization;
  List<Doctor> doctors = [];
  Doctor selectedDoctor;
  List<String> timeSlots = [
    '10:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00'
  ];
  String selectedTimeSlot;
  List<Appointment> appointments = [];
  Appointment detailedAppointment;
  List<Question> questions = [];
  List<Answer> answers = [];

  Store() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('ic_launcher');
    var ios = new IOSInitializationSettings();
    initializationSettings = new InitializationSettings(android, ios);
    selectedTimeSlot = timeSlots[0];
  }

  initializeNotifications(onSelectNotification) {
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  sendPush(String title, String body, String payload, Function onPush) async {
    initializeNotifications(onPush);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: payload);
  }

  login() async {
    String url = baseUrl + '/api/v1/login';
    var jsonUser = await Requests.get(url, json: true);

    currentUser = User.fromJson(jsonUser);
  }

  fetchAppointments() async {
    String url = baseUrl + '/api/v1/appointments?userId=${currentUser.id}';

    var jsonAppointments = await Requests.get(url, json: true);

    appointments = [];

    jsonAppointments.forEach((jsonAppointment) {
      appointments.add(Appointment.fromJson(jsonAppointment));
    });

    appointments.sort((first, second) {
      return int.parse(first.dateTimestamp) - int.parse(second.dateTimestamp);
    });

    notifyListeners();
  }

  fetchSpecializations() async {
    String url = baseUrl + '/api/v1/specializations';

    var jsonSpecializations = await Requests.get(url, json: true);

    specializations = [];

    jsonSpecializations.forEach((jsonSpecialization) {
      specializations.add(Specialization.fromJson(jsonSpecialization));
    });

    notifyListeners();
  }

  onSpecializationSelect(Specialization specialization) {
    selectedSpecialization = specialization;
    selectedDoctor = null;
    notifyListeners();

    fetchDoctors();
  }

  fetchDoctors() async {
    String url = baseUrl +
        '/api/v1/doctors?specializationId=' +
        selectedSpecialization.id.toString();

    var jsonDoctors = await Requests.get(url, json: true);

    doctors = [];

    jsonDoctors.forEach((jsonDoctor) {
      doctors.add(Doctor.fromJson(jsonDoctor));
    });

    notifyListeners();
  }

  onDoctorSelect(Doctor doctor) {
    selectedDoctor = doctor;
    notifyListeners();
  }

  onTimeSlotSelect(String timeSlot) {
    selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  onAppointmentSelect(Appointment appointment) {
    detailedAppointment = appointment;
    print(detailedAppointment);
    notifyListeners();
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    String url = baseUrl + '/api/v1/appointments';
    var body = {
      "user": {"id": appointment.user.id},
      "doctor": {"id": appointment.doctor.id},
      "dateTimestamp": appointment.dateTimestamp
    };

    var jsonAppointment = await Requests.post(url, body: body, json: true);

    Appointment createdAppointment = Appointment.fromJson(jsonAppointment);
    appointments.add(createdAppointment);

    return createdAppointment;
  }

  confirm() async {
    String url = baseUrl +
        '/api/v1/appointments/' +
        detailedAppointment.id.toString() +
        '/confirm';
    await Requests.post(url);

    detailedAppointment.isConfirmedByUser = true;

    notifyListeners();
  }

  fetchQuestions() async {
    String url = baseUrl +
        '/api/v1/questions?userId=${currentUser.id}&appointmentId=${detailedAppointment.id}';
    var jsonQuestions = await Requests.get(url, json: true);

    questions = [];
    answers = [];

    jsonQuestions.forEach((jsonQuestion) {
      questions.add(Question.fromJson(jsonQuestion));
    });

    notifyListeners();
  }

  handleAnswer(Answer answer) {
    var existingAnswerIndex = answers.indexWhere((_answer) {
      return _answer.question.id == answer.question.id;
    });

    if (existingAnswerIndex >= 0) {
      answers[existingAnswerIndex] = answer;
    } else {
      answers.add(answer);
    }

    notifyListeners();
  }

  sendAnswers() async {
    String url = baseUrl + '/api/v1/answers';

    var body = [];

    answers.forEach((answer) {
      body.add({
        "user": {"id": currentUser.id},
        "question": {"id": answer.question.id},
        "appointment": {"id": detailedAppointment.id},
        "value": answer.value
      });
    });

    await Requests.post(url, body: body, json: true);
  }
}
