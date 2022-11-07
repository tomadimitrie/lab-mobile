import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lab_ma_flutter/storage/storage.dart';
import 'package:lab_ma_flutter/types/event.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key, this.event});

  final Event? event;

  @override
  State<StatefulWidget> createState() => CreateEventViewState();
}

class CreateEventViewState extends State<CreateEventView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime date = DateTime.now();
  XFile? image;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      titleController.text = widget.event!.name;
      tagsController.text = widget.event!.tags.join(", ");
      locationController.text = widget.event!.location;
      setState(() {
        image = widget.event!.image;
      });
    }
  }

  void create(Storage storage) async {
    if (titleController.text == "" ||
        tagsController.text == "" ||
        locationController.text == "" ||
        image == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Error"),
          content: const Text("All fields required"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    final tags = tagsController.text.split(",");

    if (widget.event == null) {
      final prefs = await SharedPreferences.getInstance();
      storage.events = [
        ...storage.events,
        Event(
          name: titleController.text,
          username: prefs.getString("username") ?? "",
          location: locationController.text,
          date: date,
          image: image!,
          tags: tags,
        ),
      ];
    } else {
      widget.event!.name = titleController.text;
      widget.event!.tags = tags;
      widget.event!.location = locationController.text;
      widget.event!.date = date;
      widget.event!.image = image!;
      storage.events = [...storage.events];
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<Storage>(context);

    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text(widget.event == null ? 'Create' : "Edit"),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: (image != null
                              ? FileImage(File(image!.path))
                              : const NetworkImage(
                                  "https://via.placeholder.com/100x200",
                                )) as ImageProvider,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      setState(() {
                        this.image = image;
                      });
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CupertinoTextField(
                          placeholder: "Title",
                          controller: titleController,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CupertinoTextField(
                          placeholder: "Tags",
                          controller: tagsController,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CupertinoTextField(
                          placeholder: "Location",
                          controller: locationController,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 300,
                child: CupertinoDatePicker(
                  initialDateTime: widget.event == null ? null : widget.event!.date,
                  onDateTimeChanged: (date) {
                    setState(() {
                      this.date = date;
                    });
                  },
                ),
              ),
              CupertinoButton.filled(
                child: Text(
                  widget.event == null ? 'Create' : "Edit",
                  style: const TextStyle(color: CupertinoColors.white),
                ),
                onPressed: () {
                  create(storage);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
