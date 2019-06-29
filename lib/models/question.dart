import 'option.dart';

class Question {
  int id;
  String type;
  String text;
  List<Option> options;

  Question.fromJson(map) {
    id = map['id'];
    type = map['type'];
    text = map['text'];
    var jsonOptions = map['options'];

    options = [];

    jsonOptions.forEach((jsonOption) {
      options.add(Option.fromJson(jsonOption));
    });

    options.sort((first, second) {
      return first.order - second.order;
    });
  }
}
