class User {
  int id;
  String firstName;
  String lastName;
  String patronymic;
  String fullName;
  int age;
  String sex;

  User.fromJson(map) {
    id = map['id'];
    firstName = map['firstName'];
    lastName = map['lastName'];
    patronymic = map['patronymic'];
    age = map['age'];
    sex = map['sex'];
    fullName = '$lastName $firstName $patronymic';
  }
}