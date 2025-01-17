// 🐦 Flutter imports:

// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/exception/DioException.dart';
import 'package:infixedu/utils/model/Route.dart';
import 'package:infixedu/utils/model/Vehicle.dart';

// 📦 Package imports

// ignore: must_be_immutable
class AssignVehicle extends StatefulWidget {
  const AssignVehicle({Key? key}) : super(key: key);

  @override
  _AssignVehicleState createState() => _AssignVehicleState();
}

class _AssignVehicleState extends State<AssignVehicle> {
  TextEditingController titleController = TextEditingController();

  TextEditingController fareController = TextEditingController();

  late String _token;
  late String id;

  late Response response;

  Dio dio = Dio();

  late Future<VehicleRouteList?> getRoute;

  late Future<AssignVehicleList> getVehicle;

  late String selectedRoute;
  dynamic selectedRouteId;

  late String selectedVehicle;
  dynamic selectedVehicleId;

  bool isResponse = false;

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      _token = value!;
    }).then((value) {
      setState(() {
        Utils.getStringValue('id').then((value) {
          id = value!;
        });
        getRoute = getRouteList();
        getRoute.then((value) {
          selectedRoute = value?.routes[0].title?? "";
          selectedRouteId = value?.routes[0].id;
        });

        getVehicle = getAllVehicles();
        getVehicle.then((value) {
          selectedVehicle = value?.assignVehicle[0].vehicleNo?? "";
          selectedVehicleId = value?.assignVehicle[0].id;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWidget(
        title: 'Assign Vehicle to Route',
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Select Route'.tr,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(),
              ),
            ),
            FutureBuilder<VehicleRouteList?>(
                future: getRoute,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.routes.isNotEmpty) {
                      return getRouteDropDown(snapshot.data!.routes);
                    } else {
                      return Utils.noDataWidget();
                    }
                  } else {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Select Vehicle'.tr,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(),
              ),
            ),
            FutureBuilder<AssignVehicleList>(
                future: getVehicle,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.assignVehicle.isNotEmpty) {
                      return getVehicleDropDown(snapshot.data!.assignVehicle);
                    } else {
                      return Utils.noDataWidget();
                    }
                  } else {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                decoration: Utils.gradientBtnDecoration,
                child: Text(
                  "Save".tr,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
              onTap: assignVehicle,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: isResponse == true
                  ? const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                    )
                  : const Text(''),
            ),
          ],
        ),
      ),
    );
  }

  Widget getRouteDropDown(List<VehicleRoute> routes) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DropdownButton(
        elevation: 0,
        isExpanded: true,
        items: routes.map((item) {
          return DropdownMenuItem<String>(
            value: item.title,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
              child: Text(
                item.title!,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          );
        }).toList(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 13.0),
        onChanged: (value) {
          setState(() {
            selectedRoute = value as String;
            selectedRouteId = getCode(routes, value);
          });
        },
        value: selectedRoute,
      ),
    );
  }

  Widget getVehicleDropDown(List<Vehicle> vehicles) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DropdownButton(
        elevation: 0,
        isExpanded: true,
        items: vehicles.map((item) {
          return DropdownMenuItem<String>(
            value: item.vehicleNo,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
              child: Text(
                item.vehicleNo!,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          );
        }).toList(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 13.0),
        onChanged: (value) {
          setState(() {
            selectedVehicle = value as String;
            selectedVehicleId = getCode2(vehicles, value);
          });
        },
        value: selectedVehicle,
      ),
    );
  }


  int? getCode<T extends Iterable<VehicleRoute>?>(T? t, String title) {
    int? code;
    if (t != null) {
      for (var cls in t) {
        if (cls.title == title) {
          code = cls.id;
          break;
        }
      }
    }
    return code;
  }
  int? getCode2<T extends Iterable<Vehicle>?>(T? t, String title) {
    int? code;
    if (t != null) {
      for (var cls in t) {
        if (cls.vehicleNo == title) {
          code = cls.id;
          break;
        }
      }
    }
    return code;
  }




  // ignore: missing_return
  Future<VehicleRouteList?> getRouteList() async {
    final response = await http.get(
        Uri.parse(InfixApi.transportRoute),
        headers: Utils.setHeader(_token.toString()));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return VehicleRouteList.fromJson(data['data']);
    }
  }

  Future<AssignVehicleList> getAllVehicles() async {
    final response = await http.get(Uri.parse(InfixApi.vehicles),
        headers: Utils.setHeader(_token.toString()));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return AssignVehicleList.fromJson(jsonData['data']['assign_vehicles']);
    } else {
      throw Exception('Failed to load');
    }
  }

  assignVehicle() async {
    setState(() {
      isResponse = true;
    });
    FormData formData = FormData.fromMap({
      "route": selectedRouteId,
      "vehicles[]": [selectedVehicleId],
    });

    response = await dio
        .post(
      InfixApi.assignVehicle,
      data: formData,
      options: Options(
        headers: {
          "Accept": "application/json",
          "Authorization": _token.toString(),
        },
      ),
    )
        .catchError((e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      setState(() {
        isResponse = false;
      });
      Utils.showToast('Already Assigned');
      Utils.showToast(errorMessage);
    });

    if (response.statusCode == 200) {
      Utils.showToast(
          '$selectedVehicle ' + 'assigned to'.tr + ' $selectedRoute');
      setState(() {
        isResponse = false;
      });
      return true;
    } else if (response.statusCode == 404) {
      setState(() {
        isResponse = false;
      });
      if (response.data['success'] == false) {
        Utils.showToast(
            '$selectedVehicle ' + 'already assigned to'.tr + ' $selectedRoute');
      }
      return true;
    } else {
      return false;
    }
  }
}
