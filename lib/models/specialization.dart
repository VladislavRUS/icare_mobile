class Specialization {
  int id;
  String title;

  Specialization.fromJson(map) {
    id = map['id'];
    title = map['title'];
  }
}