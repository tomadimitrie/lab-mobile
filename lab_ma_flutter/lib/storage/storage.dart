import 'package:flutter/cupertino.dart';
import 'package:lab_ma_flutter/types/event.dart';

class Storage extends ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  set events(List<Event> events) {
    _events = events;
    notifyListeners();
  }
}