import 'dart:async';
import 'package:hive_flutter/adapters.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive/hive.dart' as hive;

import '/helpers.dart' as helpers;
import '/constants.dart' as constants;

const simpleTaskKeyOne = "com.tracker.simpleTask.one";
const simpleTaskKeyTwo = "com.tracker.simpleTask.two";
const simpleTaskKeyThree = "com.tracker.simpleTask.three";
const simpleTaskKeyFour = "com.tracker.simpleTask.four";
const simpleTaskKeyFive = "com.tracker.simpleTask.five";
const simpleTaskKeySix = "com.tracker.simpleTask.six";

const journeyID = "journey.id";
const movementID = "movemet.id";
const lastMoment = "last.moment.string";

//Save movement to sever and create a new one

Future<int> saveMovement(int id, String date) async {
  // if id == o 0 just create an new movement and return the id
  if (id == 0) {
    //make http request
    var res = await helpers.httpHelper('POST', '/api/v1/movement/', {}, {}, {});
    //check response
    if (res == null || res['id'] == null) {
      print("failed with error: unable to create movement object on server");
      return 0;
    }

    // get id from response
    var mid = res['id'] as int;
    // save id in db

    helpers.storageHelperSet('main', movementID, mid);

    //return id
    return mid;
  }

  var res = await helpers
      .httpHelper('POST', '/api/v1/movement/$id/', {'ended_at': date}, {}, {});
  if (res == null || res['id'] == null) {
    print("failed with error: unable to update movement object on server ");
    return 0;
  }

  res = await helpers.httpHelper('POST', '/api/v1/movement/', {}, {}, {});
  if (res == null || res['id'] == null) {
    print(
        "failed with error: unable to create movement second time on server ");
    return 0;
  }

  var mid = res['id'] as int;
  helpers.storageHelperSet('main', movementID, mid);

  return mid;
}

Future<int> savePoint(Map<String, Object> data) async {
  var res = await helpers.httpHelper('POST', '/api/v1/point/', data, {}, {});
  if (res == null || res['id'] == null) {
    print("failed with error: unable to create point object on server ");
    return 0;
  }
  var mid = res['id'] as int;
  return mid;
}

//Dispatcher that saves the point locally and then transfers them to the server also adding the points to movements based on the costanst constants.movementTimeoutMinute
@pragma('vm:entry-point') // Mandatory
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print("$task was executed");

      //init hive because thee app may not be on the forground
      await hive.Hive.initFlutter();

      // int jid = 0;
      // var j = await helpers.storageHelperGet('main', journeyID);
      // if (j != null) {
      //   jid = j as int;
      // }

      // check if task is six to run task six work
      if (task == simpleTaskKeySix) {
        print(
          "RUNNING UPDATER --------- TO SERVER",
        );

        int mid = 0;
        //get save current movement id
        var m = await helpers.storageHelperGet('main', movementID);
        if (m != null) {
          mid = m as int;
        }

        //if no movement saved creat one on the server and get the id
        if (mid == 0) {
          mid = await saveMovement(0, '');
          if (mid == 0) {
            return Future.value(true);
          }
        }

        print(
          "RUNNING UPDATER --------- TO SERVER 2",
        );

        //open positions in the hive
        await hive.Hive.openBox('positions');

        //get all keys in the positions collection
        var mapKeys = hive.Hive.box('positions').keys.toList();

        //get all values in the positions collection
        var mapVals = hive.Hive.box('positions').values.toList();

        // sort the values by thier creation moment
        mapVals.sort((a, b) {
          var aMap = a as Map<dynamic, dynamic>;
          var am = aMap['moment'] as String;
          var bMap = b as Map<dynamic, dynamic>;
          var bm = bMap['moment'] as String;

          return am.compareTo(bm);
        });

        print("RUNNING UPDATER --------- TO SERVER  3");

        // get the last moment saved
        String lastMomentStr = '';
        var lastInt = await helpers.storageHelperGet('main', lastMoment);
        if (lastInt != null) {
          lastMomentStr = lastInt as String;
        }

        var previousDate = DateTime.now();

        //loop through  the sorted positions
        for (var i = 0; i < mapVals.length; i++) {
          // cast elemet to dynamic
          var ele = mapVals[i] as Map<dynamic, dynamic>;

          //parse element date
          var date = DateTime.parse(ele['moment'] as String);

          //if first element check the current position moment against saved date if the time different is greater than movementTimeoutMinute save the movement on the server
          if (i == 0) {
            if (lastMomentStr != '') {
              var last = DateTime.parse(lastMomentStr);
              var diff = date.difference(last);
              if (diff.inMinutes > constants.movementTimeoutMinute) {
                mid = await saveMovement(mid, lastMomentStr);
                if (mid == 0) {
                  return Future.value(true);
                }
              }
            }
          } else {
            // else cdo the samr thing but comparing the constant to the previous movement's time
            var diff = date.difference(previousDate);
            if (diff.inMinutes > constants.movementTimeoutMinute) {
              mid = await saveMovement(
                  mid, previousDate.toUtc().toIso8601String());
              if (mid == 0) {
                return Future.value(true);
              }
            }
          }

          // the current date is now the previous date
          previousDate = date;

          //save point to server
          await savePoint({
            "movement": mid,
            "lon": ele['lon'] as Object,
            "lat": ele['lat'] as Object,
            "created": ele['moment'] as Object
          });

          print("RUNNING UPDATER --------- TO SERVER  5");

          //if it is the last moment store the movementid and the las moment
          if (i == (mapVals.length - 1)) {
            await helpers.storageHelperSet('main', movementID, mid);
            await helpers.storageHelperSet('main', lastMoment, ele['moment']);
          }
        }

        //delete all proceccesed moments
        for (var ele in mapKeys) {
          await helpers.storageHelperDelete('positions', ele);
        }
      } else {
        //all other workers save the current position to local db but do so for three minutes with 20 seconds delay
        for (var i = 0; i < 9; i++) {
          //get current position
          var pos = await helpers.determinePositionWorker();

          //create time from position or use current time
          var time = DateTime.now();
          if (pos.timestamp != null) {
            time = pos.timestamp as DateTime;
          }

          var po = {
            'lon': pos.longitude,
            'lat': pos.latitude,
            'moment': time.toUtc().toIso8601String(),
            'isPushed': false
          };

          print("RUNNING UPDATER --------- --3 running");
          // save position
          helpers.storageHelperSetNoKey('positions', po);

          print("RUNNING UPDATER --------- 000");
          //wait for 20 seconds to perform action again
          await Future.delayed(const Duration(seconds: 20));
        }
      }

      print("RUNNING UPDATER --------- 0");
    } catch (e) {
      print("$task failed. inputData =  error");
      print(e);
    }

    return Future.value(true);
  });
}
