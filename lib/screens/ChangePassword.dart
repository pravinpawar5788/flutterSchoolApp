import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late String id;
  late String _token;

  bool isResponse = false;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Utils.getStringValue('id').then((value) {
      setState(() {
        id = value!;
      });
    });
    Utils.getStringValue('token').then((value) {
      _token = value!;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'Change Password',
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: Theme.of(context).textTheme.titleLarge,
                  controller: _currentPasswordController,
                  obscureText: true,
                  validator: (String? value) {
                    // RegExp regExp = new RegExp(r'^[0-9]*$');
                    if (value!.isEmpty) {
                      return 'Please enter your current password'.tr;
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 digit'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Current Password".tr,
                    labelText: "Current Password".tr,
                    labelStyle: Theme.of(context).textTheme.headlineMedium,
                    errorStyle:
                        const TextStyle(color: Colors.pinkAccent, fontSize: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: Theme.of(context).textTheme.titleLarge,
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: (String? value) {
                    // RegExp regExp = new RegExp(r'^[0-9]*$');
                    if (value!.isEmpty) {
                      return 'Please enter a new password'.tr;
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 digit'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "New Password".tr,
                    labelText: "New Password".tr,
                    labelStyle: Theme.of(context).textTheme.headlineMedium,
                    errorStyle:
                        const TextStyle(color: Colors.pinkAccent, fontSize: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: Theme.of(context).textTheme.titleLarge,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (String? value) {
                    // RegExp regExp = new RegExp(r'^[0-9]*$');
                    if (value!.isEmpty) {
                      return 'Please confirm your password'.tr;
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 digit'.tr;
                    }
                    if (value != _newPasswordController.text) {
                      return 'New password and confirm password must be same'
                          .tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Confirm Password".tr,
                    labelText: "Confirm Password".tr,
                    labelStyle: Theme.of(context).textTheme.headlineMedium,
                    errorStyle:
                        const TextStyle(color: Colors.pinkAccent, fontSize: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    errorMaxLines: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
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
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isResponse = true;
                      });

                      var response = await http.post(
                          Uri.parse(InfixApi.changePassword(
                              _currentPasswordController.text,
                              _newPasswordController.text,
                              _confirmPasswordController.text,
                              id)),
                          headers: Utils.setHeader(_token.toString()));

                      if (response.statusCode == 200) {
                        Map data =
                            jsonDecode(response.body) as Map;

                        if (data['success'] == true) {
                          Utils.showToast('Password changed successfully'.tr);
                          Navigator.of(context).pop();
                        } else {
                          Utils.showToast(
                              'You Entered Wrong Current Password'.tr);
                        }

                        setState(() {
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                          isResponse = false;
                        });
                      } else if (response.statusCode == 404) {
                        Map data =
                            jsonDecode(response.body) as Map;

                        if (data['success'] == false) {
                          Utils.showToast(
                              'You Entered Wrong Current Password'.tr);
                        }

                        setState(() {
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                          isResponse = false;
                        });
                      }
                    } else {
                      Utils.showToast('Please correct the errors');
                    }
                  },
                ),
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
      ),
    );
  }
}
