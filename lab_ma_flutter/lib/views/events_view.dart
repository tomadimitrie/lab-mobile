import 'package:flutter/cupertino.dart';
import 'package:lab_ma_flutter/components/events_list.dart';
import 'package:lab_ma_flutter/storage/storage.dart';
import 'package:provider/provider.dart';

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<Storage>(context);

    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return const <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Events'),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventsList(storage.events),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Favorite Events",
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                EventsList(
                  storage.events
                      .where((element) => element.isFavorite)
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
