import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:visit_braila/services/localstorage_service.dart';

class QuizProvider extends ChangeNotifier {
  Map<String, int> quizes = {
    "quiz0": 0,
    "quiz1": 0,
    "quiz2": 0,
    "quiz3": 0,
    "quiz4": 0,
    "img": 0,
  };

  QuizProvider() {
    loadQuizProgress();
  }

  void loadQuizProgress() {
    String? localQuizProgress = LocalStorage.getQuizProgress();

    if (localQuizProgress == null) {
      return;
    }

    quizes = convertToInt(jsonDecode(localQuizProgress));
  }

  void saveQuizProgress(String id, int value) {
    quizes[id] = value;

    LocalStorage.saveQuizProgress(jsonEncode(quizes));

    notifyListeners();
  }

  Map<String, int> convertToInt(json) {
    return {
      "quiz0": json['quiz0'] as int,
      "quiz1": json['quiz1'] as int,
      "quiz2": json['quiz2'] as int,
      "quiz3": json['quiz3'] as int,
      "quiz4": json['quiz4'] as int,
      "img": json['img'] as int,
    };
  }
}
