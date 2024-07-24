import 'package:infixedu/screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
class SchoolIDInputScreen extends StatefulWidget {
  const SchoolIDInputScreen({Key? key}) : super(key: key);

  @override
  _SchoolIDInputScreenState createState() => _SchoolIDInputScreenState();
}

class _SchoolIDInputScreenState extends State<SchoolIDInputScreen> {
  final _schoolIDController = TextEditingController();

  void _submitSchoolID() async {
    final schoolID = _schoolIDController.text;
    if (schoolID.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('schoolID', schoolID);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Splash()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid School ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     /* appBar: AppBar(
        title: Text('Enter School ID'),
      ),*/
     appBar: AppBar(
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
            Material(
              color: Colors.transparent,
              child: SizedBox(
                height: 70.h,
                width: 70.w,
                child: IconButton(
                    tooltip: 'Back',
                    icon: Icon(
                      Icons.arrow_back,
                      size: ScreenUtil().setSp(20),
                      color: Colors.white,
                    ),
                    onPressed: () {
                      navigateToPreviousPage(context);
                    }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Text(
                  'Enter School ID',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
           /* IconButton(
              onPressed: () {
                Get.dialog(LogoutService().logoutDialog());
              },
              icon: Icon(
                Icons.exit_to_app,
                size: 25.sp,
              ),
            ),*/
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _schoolIDController,
              decoration: InputDecoration(
                labelText: 'School ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  decoration: Utils.gradientBtnDecoration,
                  child: Text(
                    "Submit".tr,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
              onTap: () {
                String reason = _schoolIDController.text;

                if (reason.isNotEmpty) {
                  setState(() {
                    //isResponse = true;
                  });
                  _submitSchoolID();
                } else {
                  Utils.showToast('Please enter schoolId'.tr);
                }
              },
            ),
            /*ElevatedButton(
              onPressed: _submitSchoolID,
              child: //Text('Submit'),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                decoration: Utils.gradientBtnDecoration,
                child: Text(
                  "Submit",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white, fontSize: 16.0),
                ),
              )
            ),*/
          ],
        ),
      ),
    );
  }
}
void navigateToPreviousPage(BuildContext context) {
  Navigator.pop(context);
}

