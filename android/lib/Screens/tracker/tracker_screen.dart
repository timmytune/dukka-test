import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:untitled/helpers.dart' as helpers;
import 'package:untitled/workers.dart' as workers;
import '../../components/background.dart';
import '../../responsive.dart';
import 'components/map.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({Key? key}) : super(key: key);

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  _TrackerScreenState() {
    //Check for current position and ask for permission
    helpers.determinePosition().then((pos) {
      // get currnwt time
      var time = DateTime.now();

      // if postion has a valid timestamp use it as time
      if (pos.timestamp != null) {
        time = pos.timestamp as DateTime;
      }

      //save position in DB
      helpers.storageHelperSetNoKey('positions', {
        'lon': pos.longitude,
        'lat': pos.latitude,
        'moment': time.toUtc().toIso8601String(),
        'isPushed': false
      });

      //Initialize background worker
      Workmanager()
          .initialize(workers.callbackDispatcher, isInDebugMode: true)
          .then((value) async {
        //Cancel previous works this should not be donr in producction
        await Workmanager().cancelAll();

        //Register worker six
        await Workmanager().registerPeriodicTask(
            workers.simpleTaskKeySix, workers.simpleTaskKeySix);

        //Register worker one
        await Workmanager().registerPeriodicTask(
            workers.simpleTaskKeyOne, workers.simpleTaskKeyOne);

        //Register worker two with 3 minutes delay
        await Workmanager().registerPeriodicTask(
            workers.simpleTaskKeyTwo, workers.simpleTaskKeyTwo,
            initialDelay: Duration(minutes: 3));

        //Register worker three with 6 minutes delay
        await Workmanager().registerPeriodicTask(
            workers.simpleTaskKeyThree, workers.simpleTaskKeyThree,
            initialDelay: Duration(minutes: 6));

        //Register worker four with 9 minutes delay
        await Workmanager().registerPeriodicTask(
            workers.simpleTaskKeyFour, workers.simpleTaskKeyFour,
            initialDelay: Duration(minutes: 9));

        //Register worker five with 12 minutes delay
        await Workmanager().registerPeriodicTask(
            workers.simpleTaskKeyFive, workers.simpleTaskKeyFive,
            initialDelay: Duration(minutes: 12));
      });
    }).catchError((error) {
      //ideally this should be a better logger
      print("GOT HERE TRACK");
      print(error);
    });
  }

  //hold all points from server
  var points = [];

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          desktop: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 450,
                      child: LoginAndSignupBtn(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          mobile: const MobileTrackerScreen(),
        ),
      ),
    );
  }
}

//mobile view for page
class MobileTrackerScreen extends StatefulWidget {
  const MobileTrackerScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MobileTrackerScreen> createState() => _MobileTrackerScreenState();
}

class _MobileTrackerScreenState extends State<MobileTrackerScreen> {
  _MobileTrackerScreenState() {
    helpers
        .httpHelper("GET", '/api/v1/point/', {}, {}, {})
        .then((res) => {
              setState(() {
                points = res['results'];
              }),
            })
        .catchError((err) => {print(err)});
  }

  var points = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: const [
            Spacer(),
            Expanded(
              flex: 8,
              child: Text(
                  "THIS WILL SHOW THE LIST OF POINTS SENT TO SERVER. IT SHOULD BE SHOWING A MAP BUT THAT IS CURRENTLY BEYOUND THE SCOPE OF THIS PROJECT"),
            ),
            Spacer(),
          ],
        ),
        SizedBox(
          height: 500.0,
          child: ListView(
            children: [
              for (var item in points)
                Text('Point: $item["lon"] | $item["lat"] | $item["created"]'),
            ],
          ),
        ),
      ],
    );
  }
}

class ListViewBuilder extends StatefulWidget {
  const ListViewBuilder({Key? key}) : super(key: key);

  @override
  State<ListViewBuilder> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<ListViewBuilder> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.0,
      child: Scaffold(
        appBar: AppBar(title: const Text("ListView.builder")),
        body: ListView.builder(
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  leading: const Icon(Icons.list),
                  trailing: const Text(
                    "GFG",
                    style: TextStyle(color: Colors.green, fontSize: 15),
                  ),
                  title: Text("List item $index"));
            }),
      ),
    );
  }
}
