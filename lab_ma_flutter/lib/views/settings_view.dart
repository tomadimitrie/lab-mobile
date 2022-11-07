import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<StatefulWidget> createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) async {
      final username = prefs.getString("username");
      usernameController.text = username ?? "";
      final interests = prefs.getString("interests");
      interestsController.text = interests ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return const <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Settings'),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CupertinoTextField(
                placeholder: "Username",
                controller: usernameController,
                onChanged: (text) async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString("username", text);
                },
              ),
              const SizedBox(
                height: 15,
              ),
              CupertinoTextField(
                placeholder: "Interests",
                controller: interestsController,
                onChanged: (text) async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString("interests", text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
