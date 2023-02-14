import 'dart:convert' as convert;
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';

// helper function to get current position and requst for the permission if not already given
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

// Helper function to determine posution in the background without asking for permission
Future<Position> determinePositionWorker() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    return Future.error('Location permissions are denied');
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

//Helper functio to send Http request with authorization
Future<dynamic> httpHelper(String method, String uri, Map<String, Object> body,
    Map<String, dynamic>? params, Map<String, String>? headers) async {
  try {
    //Generate URL, Should not be hardcoded in production
    var url = Uri.http('44.211.16.5:8000', uri);
    if (params != null && params.isNotEmpty) {
      url = Uri.http('44.211.16.5:8000', uri, params);
    }

    // create http request
    var req = http.Request(method, url);

    //get token
    var val = await storageHelperGet('auth', 'token');

    // add authorization if available
    if (val != null) {
      req.headers["Authorization"] = 'Bearer $val';
    }

    //add body if not empty
    if (body.isNotEmpty) {
      req.headers['Content-Type'] = 'application/json';
      req.body = convert.jsonEncode(body);
    }

    // add header if not empty
    if (headers != null && headers.isNotEmpty) {
      req.headers.addAll(headers);
    }

    //send request
    final response = await req.send();

    //check response code
    if (response.statusCode < 300) {
      // convert response btyte to string
      var data = await response.stream.bytesToString();
      //decode response to json
      return convert.jsonDecode(data);
    }

    var data = await response.stream.bytesToString();
    var ret = convert.jsonDecode(data);

    // check if response is null create response and add status code
    if (ret != null) {
      ret = ret as Map<String, dynamic>;
      ret["statusCode"] = response.statusCode;
      return ret;
    } else {
      return {'message': 'invalid response', 'statusCode': response.statusCode};
    }
  } catch (e) {
    print(e.toString());
    return {'message': e.toString(), 'statusCode': 501};
  }
}

Future<String> httpHelperRawResult(
    String method,
    String uri,
    Map<String, Object> body,
    Map<String, dynamic>? params,
    Map<String, String>? headers) async {
  try {
    final url = Uri.http('44.211.16.5:8000', uri, params);

    var req = http.Request(method, url);

    var val = await storageHelperGet('auth', 'token');

    if (val != null) {
      req.headers["Authorization"] = 'Bearer $val';
    }

    if (body.isNotEmpty) {
      req.headers['Content-Type'] = 'application/json';
      req.body = convert.jsonEncode(body);
    }

    if (headers != null && headers.isNotEmpty) {
      req.headers.addAll(headers);
    }

    final response = await req.send();

    return await response.stream.bytesToString();
  } catch (e) {
    print(e.toString());
    return '{"message": $e, "statusCode": 501}';
  }
}

//Get data from DB
Future<dynamic> storageHelperGet(String box, String key) async {
  var b = await Hive.openBox(box);
  return await b.get(key);
}

//Delete data from DB
Future<dynamic> storageHelperDelete(String box, Object key) async {
  var b = await Hive.openBox(box);
  return await b.delete(key);
}

//put data in DB
Future<dynamic> storageHelperSet(String box, String key, dynamic val) async {
  var b = await Hive.openBox(box);
  return await b.put(key, val);
}

//Store data with autho increment key
Future<int> storageHelperSetNoKey(String box, dynamic val) async {
  var b = await Hive.openBox(box);
  return await b.add(val);
}
