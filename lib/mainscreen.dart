import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'motoscreen.dart';
import 'tclockscreen.dart';

class mainScreen extends StatefulWidget {
  mainScreen({Key key}) : super(key: key);

  @override
  _mainScreenState createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  TextEditingController reminderController = TextEditingController();
  TextEditingController currentMilesController = TextEditingController();

  int reminderNum;
  int daysLeft = 0;

  // set user reminder
  Future<void> setReminder() async {
    var reminderSetDay = reminderController.text;
    var today = new DateTime.now();
    var nthDaysFromNow =
        today.add(new Duration(days: int.parse(reminderSetDay)));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Today's Date: $today");
    print("Reminder set for $reminderSetDay(s) days from now: $nthDaysFromNow");
    prefs.setInt('reminder_date', nthDaysFromNow.millisecondsSinceEpoch);

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // check shared prefs for saved data
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getInt("reminder_date") != null) {
        reminderNum = prefs.getInt("reminder_date");
      }
      setState(() {});
    });

    if (daysLeft == 0)
    Timer.run(() => _alertDialog());
  }

  Future<void> _alertDialog() async {
    // clear alert dialog on open
    reminderController.clear();
    // check for save data every time the dialog is open
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getInt("reminder_date") != null) {
        reminderNum = prefs.getInt("reminder_date");
        isReminderPastDue(reminderNum);
      }
    });

    return showDialog(
        context: context,
        builder: (context) {
          String contentText =
              "Select How Often You Want to Enter Your Current Odometer Reading";

    if (daysLeft <= 0) {
      Text('Please Update Your Current Miles!');
      return AlertDialog(
        title: Text("Set Reminders"),

        content: SingleChildScrollView(

            child: ListBody(
                children: <Widget>[
                  Text('Current Miles Need To Be Updated'),
                ]
            )
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('close'),
            onPressed: () {
              daysLeft = 1;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Set Reminders"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(contentText),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: reminderController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Number of Days',
                      ),
                    ),
                    Text('Days Until Update: $daysLeft'),
                    ]
                  )
                ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Save'),
                  onPressed: () {
                    setReminder();
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.alarm),
            onPressed: () {
              _alertDialog();
            },
          ),
        ],
        title: Text("R I D E W I S E"),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RaisedButton(
            color: Colors.red,
            textColor: Colors.white,
            child: Text(
              'Pre-Ride Checklist',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TclockScreen()),
              );
            },
          ),
          RaisedButton(
            color: Colors.red,
            textColor: Colors.white,
            child: Text(
              'Motorcyles',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MotoScreen()),
              );
            },
          ),
        ],
      )),
    );
  }
}
