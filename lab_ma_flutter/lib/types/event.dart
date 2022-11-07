import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Event {
  final String id = const Uuid().v4();
  String name;
  XFile image;
  DateTime date;
  String location;
  bool isFavorite = false;
  final String username;
  List<String> tags;

  Event({
    required this.name,
    required this.image,
    required this.date,
    required this.location,
    required this.username,
    required this.tags
  });
}
