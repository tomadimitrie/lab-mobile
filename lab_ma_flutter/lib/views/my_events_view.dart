import 'package:flutter/cupertino.dart';
import 'package:lab_ma_flutter/components/events_list.dart';
import 'package:lab_ma_flutter/storage/storage.dart';
import 'package:provider/provider.dart';

class MyEventsView extends StatelessWidget {
  const MyEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<Storage>(context);

    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return const <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('My Events'),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0),
          child: Column(
            children: [
              EventsList(storage.events),
            ],
          ),
        ),
      ),
    );
  }
}