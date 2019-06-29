import 'package:flutter/material.dart';
import 'package:flutter_hack/components/app_bar_text.dart';
import 'package:flutter_hack/components/big_button.dart';
import 'package:flutter_hack/components/input.dart';
import 'package:flutter_hack/components/loader.dart';
import 'package:flutter_hack/constants/app_colors.dart';
import 'package:flutter_hack/constants/durations.dart';
import 'package:flutter_hack/constants/question_types.dart';
import 'package:flutter_hack/constants/routes.dart';
import 'package:flutter_hack/models/answer.dart';
import 'package:flutter_hack/models/question.dart';
import 'package:scoped_model/scoped_model.dart';

import '../store.dart';

class QuestionsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return QuestionsScreenState();
  }
}

class QuestionsScreenState extends State<QuestionsScreen> {
  bool isLoading = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    showLoader();
    await fetchQuestions();
    hideLoader();
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

  fetchQuestions() async {
    Store store = ScopedModel.of<Store>(context);

    await Future.delayed(Duration(milliseconds: Durations.REQUEST_DELAY_MS));

    try {
      await store.fetchQuestions();
    } catch (e) {
      print(e);
    }
  }

  List<Widget> buildQuestionsList(bool isKeyboardShowing) {
    Store store = ScopedModel.of<Store>(context);

    var index = 0;

    List<Widget> questions = store.questions.map((question) {
      return Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(
              bottom: index == store.questions.length - 1 && !isKeyboardShowing
                  ? 90
                  : 10,
              top: index++ == 0 ? 10 : 0),
          child: buildQuestion(question));
    }).toList();

    return questions;
  }

  Widget buildQuestionText(Question question) {
    return Container(
        margin: EdgeInsets.only(bottom: 15),
        child:
            Text(question.text, style: TextStyle(fontWeight: FontWeight.w500)));
  }

  Widget buildQuestion(Question question) {
    if (question.type == QuestionTypes.SINGLE_SELECT) {
      return buildSingleSelectQuestion(question);
    } else if (question.type == QuestionTypes.RATING) {
      return buildRatingQuestion(question);
    } else {
      return buildCommentQuestion(question);
    }
  }

  Widget buildSingleSelectQuestion(Question question) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildQuestionText(question),
          buildQuestionOptions(question)
        ],
      ),
    );
  }

  Widget buildQuestionOptions(Question question) {
    Store store = ScopedModel.of<Store>(context);

    Answer answer = store.answers.firstWhere((answer) {
      return answer.question.id == question.id;
    }, orElse: () => null);

    List<Widget> options = question.options.map((option) {
      bool isSelected = false;

      if (answer != null) {
        isSelected = option.id.toString() == answer.value;
      }

      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Material(
          color: Color.fromARGB(20, 0, 0, 0),
          child: InkWell(
            onTap: () {
              Answer answer = Answer();
              answer.question = question;
              answer.value = option.id.toString();
              store.handleAnswer(answer);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Text(option.text),
                  Spacer(),
                  Opacity(
                    opacity: isSelected ? 1 : 0,
                    child: Icon(
                      Icons.check,
                      size: 15,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: options,
      ),
    );
  }

  Widget buildRatingQuestion(Question question) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildQuestionText(question), buildStars(question)],
      ),
    );
  }

  Widget buildStars(Question question) {
    List<Widget> stars = [];
    Store store = ScopedModel.of<Store>(context);

    Answer answer = store.answers.firstWhere((answer) {
      return answer.question.id == question.id;
    }, orElse: () => null);

    for (int i = 0; i < 5; i++) {
      bool isHighlighted = false;

      if (answer != null) {
        var intValue = int.parse(answer.value);

        isHighlighted = i <= intValue;
      }

      stars.add(Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Answer answer = Answer();
            answer.question = question;
            answer.value = i.toString();
            store.handleAnswer(answer);
          },
          child: Container(
            child: Icon(
              Icons.star,
              size: 40,
              color:
                  isHighlighted ? Colors.yellow : Color.fromARGB(40, 0, 0, 0),
            ),
          ),
        ),
      ));
    }

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: stars,
    );
  }

  Widget buildCommentQuestion(Question question) {
    Store store = ScopedModel.of<Store>(context);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildQuestionText(question),
          Input(
            onChanged: (value) {
              Answer answer = Answer();
              answer.question = question;
              answer.value = value;
              store.handleAnswer(answer);
            },
            hintText: 'Введите текст',
            maxLines: 5,
          )
        ],
      ),
    );
  }

  onSendAnswers() async {
    setState(() {
      isSending = true;
    });

    await Future.delayed(Duration(milliseconds: Durations.REQUEST_DELAY_MS));
    Store store = ScopedModel.of<Store>(context);

    try {
      await store.sendAnswers();
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScopedModel.of<Store>(context, rebuildOnChange: true);

    bool isKeyboardShowing = MediaQuery.of(context).viewInsets.vertical > 0;

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
        title: AppBarText(text: 'Опрос'),
      ),
      backgroundColor: AppColors.BACKGROUND_COLOR,
      body: isLoading
          ? Center(
              child: Loader(),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: buildQuestionsList(isKeyboardShowing),
                              )),
                        ),
                        !isKeyboardShowing
                            ? Positioned(
                                left: 10,
                                right: 10,
                                bottom: 20,
                                child: BigButton(
                                    isDisabled: isDisabled(),
                                    text: 'Отправить',
                                    onTap: onSendAnswers,
                                    isLoading: isSending),
                              )
                            : null
                      ].where((widget) => widget != null).toList(),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  bool isDisabled() {
    Store store = ScopedModel.of<Store>(context);
    for (var i = 0; i < store.questions.length; i++) {
      var answer = store.answers.firstWhere((answer) {
        return answer.question.id == store.questions[i].id;
      }, orElse: () => null);

      if (answer == null) {
        return true;
      }
    }

    return false;
  }
}
