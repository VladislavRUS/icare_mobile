class Option {
  int id;
  int order;
  String text;

  Option.fromJson(map) {
    id = map['id'];
    order = map['order'];
    text = map['text'];
  }
}