// Flutter imports:
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:infixedu/config/app_config.dart';

// Project imports:

import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/DayWiseRoutine.dart';
import 'package:infixedu/utils/server/LogoutService.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class StudentRoutine extends StatefulWidget {
  dynamic classCode;
  dynamic sectionCode;

  StudentRoutine(this.classCode, this.sectionCode, {Key? key}) : super(key: key);

  @override
  State<StudentRoutine> createState() => _StudentRoutineState();
}

class _StudentRoutineState extends State<StudentRoutine>
    with SingleTickerProviderStateMixin {
  List<SmWeekend> weeks = [];

  var _token;

  late TabController tabController;

  List<Widget> tabs = [];

  late Future<DayWiseRoutine> routine;

  Future<DayWiseRoutine> getRoutine(day) async {
    final response = await http.post(Uri.parse(InfixApi.getDayWiseRoutine),
        headers: Utils.setHeader(_token.toString()),
        body: jsonEncode({
          'day_id': day,
          'class_id': widget.classCode,
          'section_id': widget.sectionCode,
        }));
    if (response.statusCode == 200) {
      var data = dayWiseRoutineFromJson(response.body);
      weeks.addAll(data.smWeekends as Iterable<SmWeekend>);
      setState(() {
        tabController =
            TabController(length: data.smWeekends!.length, vsync: this);

        for (var element in data.smWeekends!) {
          tabs.add(Text(element.name!));
        }
      });
      return data;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load routine');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await Utils.getStringValue('token').then((value) {
      setState(() {
        _token = value;
      });
    }).then((value) async {
      routine = getRoutine(1);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DayWiseRoutine>(
        future: routine,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
          } else {
            if (snapshot.hasData) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  toolbarHeight: 70,
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppConfig.appToolbarBackground),
                        fit: BoxFit.fill,
                      ),
                      color: Colors.deepPurple,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            height: 50.h,
                            width: 50.w,
                            child: IconButton(
                                tooltip: 'Back',
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: ScreenUtil().setSp(20),
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ),
                        ),
                        Container(
                          width: 1.w,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              "Routine".tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontSize: 18.sp, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        IconButton(
                          onPressed: () {
                            Get.dialog(LogoutService().logoutDialog());
                          },
                          icon: Icon(
                            Icons.exit_to_app,
                            size: 25.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  bottom: TabBar(
                    controller: tabController,
                    tabs: tabs,
                    labelColor: Colors.white,
                    labelPadding: const EdgeInsets.all(10),
                    isScrollable: true,
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                body: TabBarView(
                    controller: tabController,
                    children: List.generate(tabs.length, (index) {
                      return RoutineListWidget(
                        dayId: snapshot.data!.smWeekends![index].id!,
                        classId: widget.classCode,
                        sectionId: widget.sectionCode,
                      );
                    })),
              );
            } else {
              return Utils.noDataWidget();
            }
          }
        });
  }
}

class RoutineListWidget extends StatelessWidget {
  final int dayId;
  final int classId;
  final int sectionId;
  const RoutineListWidget({Key? key, required this.dayId, required this.classId, required this.sectionId}) : super(key: key);

  Future<DayWiseRoutine> getRoutine() async {
    String? _token;
    await Utils.getStringValue('token').then((value) {
      _token = value;
    });
    final response = await http.post(Uri.parse(InfixApi.getDayWiseRoutine),
        headers: Utils.setHeader(_token.toString()),
        body: jsonEncode({
          'day_id': dayId,
          'class_id': classId,
          'section_id': sectionId,
        }));
    if (response.statusCode == 200) {
      var data = dayWiseRoutineFromJson(response.body);
      return data;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load routine');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DayWiseRoutine>(
        future: getRoutine(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            if (snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Subject'.tr,
                            textAlign: TextAlign.start,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Time'.tr,
                            textAlign: TextAlign.start,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Room'.tr,
                            textAlign: TextAlign.start,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.classRoutines!.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemBuilder: (context, routineIndex) {
                          var classRoutines = snapshot.data?.classRoutines;
                          var subjects = snapshot.data?.subjects;
                          var rooms = snapshot.data?.rooms;

                          if (classRoutines == null || subjects == null || rooms == null) {
                            return const SizedBox.shrink(); // Handle null case appropriately
                          }

                          var routine = classRoutines[routineIndex];
                          var filteredSubjects = subjects.where((element) => element.id == routine.subjectId).toList();
                          var filteredRooms = rooms.where((element) => element.id == routine.roomId).toList();

                          if (filteredSubjects.isEmpty || filteredRooms.isEmpty) {
                            return const SizedBox.shrink(); // Handle case where no matching subject or room is found
                          }

                          var getSubjectName = filteredSubjects.first;
                          var getRoomNumber = filteredRooms.first;

                          var startTime = DateFormat.jm().format(
                              DateFormat("hh:mm:ss").parse(routine.startTime!));
                          var endTime = DateFormat.jm().format(
                              DateFormat("hh:mm:ss").parse(routine.endTime!));

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${getSubjectName.subjectName} (${getSubjectName.subjectCode}) ${getSubjectName.subjectType}',
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$startTime - $endTime',
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  getRoomNumber.roomNo!,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w100,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Utils.noDataWidget();
            }
          }
        });
  }
}
