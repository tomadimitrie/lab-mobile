import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:lab_ma_flutter/storage/storage.dart';
import 'package:lab_ma_flutter/types/event.dart';
import 'package:lab_ma_flutter/views/create_event_view.dart';
import 'package:provider/provider.dart';

class EventsList extends StatelessWidget {
  final List<Event> events;

  const EventsList(this.events, {super.key});

  void delete(BuildContext context, Storage storage, Event event) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to delete?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text("Yes"),
            onPressed: () {
              storage.events = storage.events
                  .where((element) => element.id != event.id)
                  .toList();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void update(Storage storage, Event event) {
    event.isFavorite = !event.isFavorite;
    storage.events = [...storage.events];
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<Storage>(context);

    return SizedBox(
      height: 400,
      child: ListView.separated(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Container(
            width: 150,
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: FileImage(File(event.image.path)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            child: const Icon(
                              CupertinoIcons.pencil,
                              size: 40,
                            ),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => ChangeNotifierProvider.value(
                                  value: storage,
                                  child: CreateEventView(event: event),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: const Icon(
                              CupertinoIcons.trash,
                              size: 40,
                            ),
                            onTap: () => delete(context, storage, event),
                          ),
                          GestureDetector(
                            child: Icon(
                              event.isFavorite
                                  ? CupertinoIcons.star_fill
                                  : CupertinoIcons.star,
                              size: 40,
                            ),
                            onTap: () => update(storage, event),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  event.name,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${event.date.year}-${event.date.month}-${event.date.day}, ${event.date.hour}:${event.date.minute}",
                                ),
                                Text(event.location)
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(
          width: 15,
        ),
      ),
    );
  }
}
