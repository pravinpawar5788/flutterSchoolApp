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

// ignore: must_be_immutable
class AddRoute extends StatefulWidget {
  const AddRoute({Key? key}) : super(key: key);

  @override
  _AddRouteState createState() => _AddRouteState();
}

class _AddRouteState extends State<AddRoute> {
  TextEditingController titleController = TextEditingController();

  TextEditingController fareController = TextEditingController();

  late String _token;
  late String id;

  late Response response;

  Dio dio = Dio();

  late Future<VehicleRouteList>? getRoute;

  static List<Tab> tabs = <Tab>[
    Tab(
      text: 'Route List'.tr,
    ),
    Tab(
      text: 'Add New'.tr,
    ),
  ];

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      _token = value!;
    }).then((value) {
      setState(() {
        Utils.getStringValue('id').then((value) {
          id = value!;
        });
        getRoute = getRouteList() as Future<VehicleRouteList>?;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWidget(
        title: 'Route',
      ),
      body: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: DefaultTabController(
          length: tabs.length,
          initialIndex: 0,
          child: Builder(
            builder: (context) {
              final TabController tabController =
                  DefaultTabController.of(context);
              tabController.addListener(() {
                if (tabController.indexIsChanging) {
                  debugPrint('${tabController.index}');
                }
              });
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  title: TabBar(
                    labelColor: Colors.black,
                    labelPadding: EdgeInsets.zero,
                    indicatorColor: Colors.purple,
                    tabs: tabs,
                    indicatorPadding: EdgeInsets.zero,
                    labelStyle: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: TabBarView(
                    children: [
                      routeList(),
                      addRoute(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget routeList() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Route'.tr,
                  maxLines: 1,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Fare'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: FutureBuilder<VehicleRouteList>(
                future: getRoute,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.routes.isNotEmpty) {
                      return ListView.separated(
                          itemCount: snapshot.data!.routes.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (context, index) {
                            return Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    snapshot.data!.routes![index].title?? "",
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.headlineMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    snapshot.data!.routes[index].far.toString(),
                                    style:
                                        Theme.of(context).textTheme.headlineMedium,
                                  ),
                                ),
                              ],
                            );
                          });
                    } else {
                      return Utils.noDataWidget();
                    }
                  } else {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget addRoute() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            style: Theme.of(context).textTheme.headlineMedium,
            decoration: InputDecoration(hintText: 'Route title here'.tr),
          ),
          TextField(
            controller: fareController,
            style: Theme.of(context).textTheme.headlineMedium,
            decoration: InputDecoration(hintText: 'Enter fare here'.tr),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 16.0),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              onPressed: () {
                addRouteData(titleController.text, fareController.text, id)
                    .then((value) {
                  if (value) {
                    titleController.text = '';
                    fareController.text = '';
                  }
                });
              },
              child: Text("Save".tr),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: missing_return
  Future<VehicleRouteList?> getRouteList() async {
    final response = await http.get(Uri.parse(InfixApi.transportRoute),
        headers: Utils.setHeader(_token.toString()));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return VehicleRouteList.fromJson(data['data']);
    }
  }

  Future<bool> addRouteData(String title, String fare, String uid) async {
    response = await dio
        .post(
      InfixApi.addRoute(title, fare, uid),
      options: Options(
        headers: {
          "Accept": "application/json",
          "Authorization": _token.toString(),
        },
      ),
    )
        .catchError((e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      debugPrint(errorMessage);
      Utils.showToast(errorMessage);
    });
    if (response.statusCode == 200) {
      Utils.showToast('Route Added');
      return true;
    } else {
      return false;
    }
  }
}
