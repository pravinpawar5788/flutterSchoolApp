import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/controller/user_controller.dart';
import 'package:infixedu/utils/FunctinsData.dart';
import 'package:infixedu/utils/StudentRecordWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/Routine.dart';
import 'package:infixedu/utils/model/StudentRecord.dart';
import 'package:infixedu/utils/server/LogoutService.dart';

class DBStudentRoutine extends StatefulWidget {
  String? id;

  DBStudentRoutine({Key? key, this.id}) : super(key: key);

  @override
  State<DBStudentRoutine> createState() => _DBStudentRoutineState();
}

class _DBStudentRoutineState extends State<DBStudentRoutine>
    with SingleTickerProviderStateMixin {

  final UserController _userController = Get.put(UserController());
  List<String> weeks = AppFunction.weeks;
  TabController? _tabController;
  var _token;
  Future<Routine>? routine;
  late int initialIndex;

  Future<Routine> getRoutine(int recordId) async {
    try {
      final response = await http.get(
        Uri.parse(InfixApi.routineView(widget.id, "student", recordId: recordId)),
        headers: Utils.setHeader(_token.toString()),
      );
      if (response.statusCode == 200) {
        var data = routineFromJson(response.body);
        print('Response: ${response.body}');
        return data;
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void getInitialDay() {
    DateTime now = DateTime.now();
    final today = DateFormat('EEEE').format(now);
    switch (today) {
      case "Saturday":
        initialIndex = 0;
        break;
      case "Sunday":
        initialIndex = 1;
        break;
      case "Monday":
        initialIndex = 2;
        break;
      case "Tuesday":
        initialIndex = 3;
        break;
      case "Wednesday":
        initialIndex = 4;
        break;
      case "Thursday":
        initialIndex = 5;
        break;
      case "Friday":
        initialIndex = 6;
        break;
      default:
        initialIndex = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    getInitialDay();
    if (initialIndex >= weeks.length) {
      initialIndex = 0; // Set to a default valid index if out of range
    }
    _tabController = TabController(length: weeks.length, initialIndex: initialIndex, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userController.selectedRecord.value = _userController.studentRecord.value.records!.first;
    Utils.getStringValue('token').then((value) {
      setState(() {
        _token = value;
        routine = getRoutine(_userController.studentRecord.value.records!.first.id!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(top: 20.h),
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
                Container(width: 25.w),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Text(
                      "Routine".tr,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 18.sp, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudentRecordWidget(
              onTap: (Record record) {
                _userController.selectedRecord.value = record;
                setState(() {
                  routine = getRoutine(record.id!);
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<Routine>(
                future: routine,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.classRoutines!.isNotEmpty) {
                        return Column(
                          children: [
                            PreferredSize(
                              preferredSize: const Size.fromHeight(0),
                              child: TabBar(
                                isScrollable: true,
                                controller: _tabController,
                                indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2.0),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xff006cd1), Color(0xff2e9aff)],
                                    )),
                                labelColor: Colors.white,
                                unselectedLabelColor: const Color(0xFF415094),
                                indicatorSize: TabBarIndicatorSize.tab,
                                automaticIndicatorColorAdjustment: true,
                                tabs: List.generate(
                                  weeks.length,
                                      (index) => Tab(
                                    height: 24,
                                    text: weeks[index].substring(0, 3).toUpperCase(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: List.generate(weeks.length, (index) {
                                  List<ClassRoutine> classRoutines = snapshot
                                      .data!.classRoutines!
                                      .where((element) => element.day == weeks[index])
                                      .toList();

                                  return classRoutines.isEmpty
                                      ? Utils.noDataWidget()
                                      : Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListView.separated(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: classRoutines.length,
                                      shrinkWrap: true,
                                      separatorBuilder: (context, index) {
                                        return Container(
                                          height: 0.2,
                                          margin: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft,
                                                colors: [Colors.purple, Colors.deepPurple]),
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, rowIndex) {
                                        return Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Time'.tr + ":",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                      classRoutines[rowIndex].startTime != null ||
                                                          classRoutines[rowIndex].startTime != null
                                                          ? classRoutines[rowIndex].startTime! +
                                                          ' - ' +
                                                          classRoutines[rowIndex].endTime!
                                                          : "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(fontWeight: FontWeight.normal)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Subject'.tr + ":",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                      classRoutines[rowIndex].subject ?? "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(fontWeight: FontWeight.normal)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Room'.tr + ":",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                      classRoutines[rowIndex].room ?? "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(fontWeight: FontWeight.normal)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Teacher'.tr + ":",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                      classRoutines[rowIndex].teacher ?? "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(fontWeight: FontWeight.normal)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    } else {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
