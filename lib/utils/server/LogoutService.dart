// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// Project imports:

import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/controller/user_controller.dart';
import 'package:infixedu/controller/system_controller.dart';
import 'package:infixedu/controller/notification_controller.dart';
import 'package:infixedu/language/translation.dart';
import 'package:infixedu/utils/widget/cc.dart';
import 'package:infixedu/screens/teacher/attendance/attendance_controller.dart';
import 'package:infixedu/screens/teacher/attendance/subject_attendance_controller.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class LogoutService {

  logoutDialog() {
    String? _token;
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: Get.textTheme.headlineSmall?.copyWith(
          fontSize: 12.sp,
          color: Colors.red,
        ),
      ),
      onPressed: () {
        Get.back(closeOverlays: true);
      },
    );
    Widget yesButton = TextButton(
      child: Text(
        "Yes",
        style: Get.textTheme.headlineSmall?.copyWith(
          fontSize: ScreenUtil().setSp(12),
          color: Colors.green,
        ),
      ),
      onPressed: () async {
        await Utils.getStringValue('token').then((value) {
          _token = value;
        });
        Utils.clearAllValue();

        Get.offNamedUntil("/", ModalRoute.withName('/'));

        var response = await http.post(Uri.parse(InfixApi.logout()),
            headers: Utils.setHeader(_token.toString()));
        if (response.statusCode == 200) {
          await DefaultCacheManager().emptyCache();

          Get.delete<UserController>();
          Get.delete<SystemController>();
          Get.delete<NotificationController>();
          Get.delete<LanguageController>();
          Get.delete<CustomController>();
          Get.delete<GetMaterialController>();
          Get.delete<SubjectAttendanceController>();
          Get.delete<AttendanceController>();
          //AttendanceController
          } else {
          Utils.showToast('Unable to logout');
        }
      },
    );




    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Logout",
        style: Get.textTheme.headlineSmall,
      ),
      content: const Text("Would you like to logout?"),
      actions: [
        cancelButton,
        yesButton,
      ],
    );

    // show the dialog
    return alert;
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return alert;
    //   },
    // );
  }
}
