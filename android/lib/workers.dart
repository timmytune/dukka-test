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

Future<int> saveMovement(int id, String date) async {
  if (id == 0) {
    var res = await helpers.httpHelper('POST', '/api/v1/movement/', {}, {}, {});
    if (res == null || res['id'] == null) {
      print("failed with error: unable to create movement object on server");
      return 0;
    }
    var mid = res['id'] as int;
    helpers.storageHelperSet('main', movementID, mid);

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

@pragma('vm:entry-point') // Mandatory
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print("$task was executed");

      await hive.Hive.initFlutter();

      // int jid = 0;
      // var j = await helpers.storageHelperGet('main', journeyID);
      // if (j != null) {
      //   jid = j as int;
      // }

      if (task == simpleTaskKeySix) {
        print(
          "RUNNING UPDATER --------- TO SERVER",
        );

        int mid = 0;
        var m = await helpers.storageHelperGet('main', movementID);
        if (m != null) {
          mid = m as int;
        }

        if (mid == 0) {
          mid = await saveMovement(0, '');
          if (mid == 0) {
            return Future.value(true);
          }
        }

        print(
          "RUNNING UPDATER --------- TO SERVER 2",
        );

        print(mid);

        await hive.Hive.openBox('positions');

        var mapKeys = hive.Hive.box('positions').keys.toList();
        var mapVals = hive.Hive.box('positions').values.toList();

        mapVals.sort((a, b) {
          var aMap = a as Map<dynamic, dynamic>;
          var am = aMap['moment'] as String;
          var bMap = b as Map<dynamic, dynamic>;
          var bm = bMap['moment'] as String;

          return am.compareTo(bm);
        });

        print("RUNNING UPDATER --------- TO SERVER  3");

        String lastMomentStr = '';
        var lastInt = await helpers.storageHelperGet('main', lastMoment);
        if (lastInt != null) {
          lastMomentStr = lastInt as String;
        }

        var previousDate = DateTime.now();

        for (var i = 0; i < mapVals.length; i++) {
          var ele = mapVals[i] as Map<dynamic, dynamic>;
          var date = DateTime.parse(ele['moment'] as String);
          print("RUNNING UPDATER --------- TO SERVER  4");

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
            var diff = date.difference(previousDate);
            if (diff.inMinutes > constants.movementTimeoutMinute) {
              mid = await saveMovement(
                  mid, previousDate.toUtc().toIso8601String());
              if (mid == 0) {
                return Future.value(true);
              }
            }
          }

          previousDate = date;

          await savePoint({
            "movement": mid,
            "lon": ele['lon'] as Object,
            "lat": ele['lat'] as Object,
            "created": ele['moment'] as Object
          });

          print("RUNNING UPDATER --------- TO SERVER  5");

          if (i == (mapVals.length - 1)) {
            await helpers.storageHelperSet('main', movementID, mid);
            await helpers.storageHelperSet('main', lastMoment, ele['moment']);
          }
        }

        for (var ele in mapKeys) {
          await helpers.storageHelperDelete('positions', ele);
        }
      } else {
        for (var i = 0; i < 9; i++) {
          var pos = await helpers.determinePositionWorker();

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

          helpers.storageHelperSetNoKey('positions', po);

          print("RUNNING UPDATER --------- 000");

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
