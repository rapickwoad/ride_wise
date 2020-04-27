import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotoScreen extends StatefulWidget {
  MotoScreen({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MotoScreenState createState() => _MotoScreenState();
}

class _MotoScreenState extends State<MotoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> make = <String>[];
  List<String> model = <String>[];
  List<String> miles = <String>[];
  List<String> servicePeriod = <String>[];
  List<String> lastService = <String>[];
  List<String> serviceIn = <String>[];
  List<String> _imagesLocation = <String>[];

  File image = new File('');

  TextEditingController makeController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController milesController = TextEditingController();
  TextEditingController servicePeriodController = TextEditingController();
  TextEditingController lastServiceController = TextEditingController();

  Future<void> addItemToList({int index}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    File f = await getImageFileFromAssets('choppy_2020.png');

    // delete old index in edit mode on save
    if (index != null) {
      make.removeAt(index);
      model.removeAt(index);
      miles.removeAt(index);
      servicePeriod.removeAt(index);
      lastService.removeAt(index);
      serviceIn.removeAt(index);
      _imagesLocation.removeAt(index);
    }
    // save data
    setState(() {
      index = index ?? 0;
      make.insert(index, makeController.text);
      model.insert(index, modelController.text);
      miles.insert(index, milesController.text);
      servicePeriod.insert(index, servicePeriodController.text);
      lastService.insert(index, lastServiceController.text);
      serviceIn.insert(index, nextService());
      if (image.path == '') {
        _imagesLocation.insert(index, f.path);
      } else {
        _imagesLocation.insert(index, image.path);
      }
      prefs.setStringList('makeList', make);
      prefs.setStringList('modelList', model);
      prefs.setStringList('milesList', miles);
      prefs.setStringList('servicePeriodList', servicePeriod);
      prefs.setStringList('lastServiceList', lastService);
      prefs.setStringList('serviceInList', serviceIn);
      prefs.setStringList('imagesLocationList', _imagesLocation);
    });
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future getImage() async {
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future clearAll() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    make.clear();
    model.clear();
    miles.clear();
    servicePeriod.clear();
    lastService.clear();
    serviceIn.clear();
  }

  TextEditingController reminderController = TextEditingController();

  int reminderNum;
  int daysLeft = 0;

  // set user reminder
  Future<void> setReminder(String reminderDateKey) async {
    var reminderSetDay = reminderController.text;
    var today = new DateTime.now();
    var nthDaysFromNow =
        today.add(new Duration(days: int.parse(reminderSetDay)));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Today's Date: $today");
    print("Reminder set for $reminderSetDay(s) days from now: $nthDaysFromNow");
    prefs.setInt(reminderDateKey, nthDaysFromNow.millisecondsSinceEpoch);

    return nthDaysFromNow;
  }

  // check reminder expiration date
  void isReminderPastDue(int reminderDateEpoch) {
    DateTime today = new DateTime.now();
    DateTime reminderDate =
        DateTime.fromMillisecondsSinceEpoch(reminderDateEpoch);
    SharedPreferences.getInstance().then((prefs) {
      print("Today's Date: $today");
      print("Reminder Date: $reminderDate");
      // check user saved reminder date against today
      reminderDate.isAfter(today)
          ? print("Reminder has not expired")
          : print("Reminder has expired!");
      daysLeft = reminderDate.difference(today).inDays;

      return reminderDate.isBefore(today);
    });
  }

  Future<void> _addBikeAlertDialog({int index}) async {
    if (index != null) {
      // we're in edit mode -- skip saving and load alert with saved data
      makeController.text = make[index];
      modelController.text = model[index];
      milesController.text = miles[index];
      servicePeriodController.text = servicePeriod[index];
      lastServiceController.text = lastService[index];
    } else {
      image = File('');
      print('Image File Path - ${image.path}');
      // clearing text fields on open
      makeController.clear();
      modelController.clear();
      milesController.clear();
      servicePeriodController.clear();
      lastServiceController.clear();
    }
    return showDialog(
      context: context,
      builder: (context) {
        String contentText = "Please Enter Requested Information";
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text("Create or Edit Motorcycle Profile"),
                content: Column(
                  children: <Widget>[
                    Text(contentText),
                    TextField(
                      controller: makeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Make Name',
                      ),
                    ),
                    TextField(
                      controller: modelController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Model Name',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: milesController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Current Miles',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: servicePeriodController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Miles Between Oil Changes',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: lastServiceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Miles at Last Service',
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Save'),
                    onPressed: () {

                      // asset the text controllers aren't empty
                      if (makeController.text.trim() != '' &&
                          modelController.text.trim() != '' &&
                          milesController.text.trim() != '' &&
                          servicePeriodController.text.trim() != '' &&
                          lastServiceController.text.trim() != '') {
                        if (index != null) {
                          // in edit mode
                          print("In edit mode");
                          addItemToList(index: index);
                        } else {
                          // in add mode
                          print("In add mode");
                          addItemToList();
                        }
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pop();
                        // Find the Scaffold in the widget tree and use it to show a SnackBar.
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(
                          content:
                              new Text("Please don't leave any fields blank."),
                          duration: Duration(seconds: 2),
                        ));
                      }
                    },
                  ),
                  FlatButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                      makeController.clear();
                      modelController.clear();
                      milesController.clear();
                      servicePeriodController.clear();
                      lastServiceController.clear();
                    },
                  ),
                  IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.add_a_photo),
                    onPressed: () {
                      setState(() {
                        getImage();
                        contentText = "Image selected";
                      });
                    },
                    tooltip: 'Pick Image',
                  ),
                ]);
          },
        );
      },
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // check shared prefs for saved data
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getStringList("makeList") != null) {
        make = prefs.getStringList("makeList");
      }
      if (prefs.getStringList("modelList") != null) {
        model = prefs.getStringList("modelList");
      }
      if (prefs.getStringList("milesList") != null) {
        miles = prefs.getStringList("milesList");
      }
      if (prefs.getStringList("servicePeriodList") != null) {
        servicePeriod = prefs.getStringList("servicePeriodList");
      }
      if (prefs.getStringList("lastServiceList") != null) {
        lastService = prefs.getStringList("lastServiceList");
      }
      if (prefs.getStringList("serviceInList") != null) {
        serviceIn = prefs.getStringList("serviceInList");
      }
      if (prefs.getStringList("imagesLocationList") != null) {
        _imagesLocation = prefs.getStringList("imagesLocationList");
      }

      // check shared prefs for saved data
      if (prefs.getInt("reminder_date") != null) {
        reminderNum = prefs.getInt("reminder_date");
      }
      setState(() {});
    });
  }

  nextService() {
    String nextService;
    var service = int.parse(lastServiceController.text) +
        int.parse(servicePeriodController.text) -
        int.parse(milesController.text);
    nextService = service.toString();
    print(nextService);
    return nextService;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.delete),
                onPressed: () {
                  clearAll();
                  setState(() {});
                }),
          ],
          title: Text('Motorcycles'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: make.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // pop reminder dialog on tap
                          // TODO: Change this to be the key reminder date key for whatever bike
                          // TODO: and replace it here so that it uses index to pull from a list.
                          _addBikeAlertDialog(index: index);
                        },
                        child: Container(
                            height: 100,
                            margin: EdgeInsets.all(2),
                            color: Colors.red,
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    height: 100.0,
                                    child: Image.file(
                                        File(_imagesLocation[index])),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${make[index]}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${model[index]}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Current Miles: ${miles[index]}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Service Period: ${servicePeriod[index]} miles',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Next Service: ${serviceIn[index]} miles',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      );
                    }))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _addBikeAlertDialog();
          },
          label: Text('Add Motorcycle'),
          icon: Icon(Icons.add_circle),
        ));
  }
}
