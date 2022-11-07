import 'package:flutter/cupertino.dart';
import 'package:lab_ma_flutter/views/create_event_view.dart';
import 'package:lab_ma_flutter/views/events_view.dart';
import 'package:lab_ma_flutter/views/my_events_view.dart';
import 'package:lab_ma_flutter/views/settings_view.dart';
import 'package:lab_ma_flutter/storage/storage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Storage(),
          ),
        ],
        child: CupertinoTabScaffold(
          tabBuilder: (context, index) {
            return const [
              EventsView(),
              MyEventsView(),
              CreateEventView(),
              SettingsView()
            ][index];
          },
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.add),
                label: "Events",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.add),
                label: "My Events",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.add),
                label: "Create",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.add),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
