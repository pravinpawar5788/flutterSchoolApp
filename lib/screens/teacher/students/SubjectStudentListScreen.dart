import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/model/Student.dart';
import 'package:infixedu/utils/widget/SubjectStudentSearchRow.dart';

// ignore: must_be_immutable
class SubjectStudentListScreen extends StatefulWidget {
  dynamic classCode;
  dynamic sectionCode;
  dynamic subjectCode;
  String? name;
  String? roll;
  String? url;
  String? status;
  String? token;
  String? subjectName;

  SubjectStudentListScreen(
      {Key? key, this.classCode,
      this.sectionCode,
      this.subjectCode,
      this.name,
      this.roll,
      this.url,
      this.status,
      this.token,
      this.subjectName}) : super(key: key);

  @override
  _SubjectStudentListScreenState createState() =>
      // ignore: no_logic_in_create_state
      _SubjectStudentListScreenState(
          classCode: classCode,
          sectionCode: sectionCode,
          subjectCode: subjectCode,
          name: name,
          roll: roll,
          url: url,
          status: status,
          token: token,
          subjectName: subjectName);
}

class _SubjectStudentListScreenState extends State<SubjectStudentListScreen> {
  dynamic classCode;
  dynamic sectionCode;
  dynamic subjectCode;
  String? name;
  String? roll;
  String? url;
  Future<StudentList>? students;
  String? status;
  String? token;
  String? subjectName;

  _SubjectStudentListScreenState(
      {this.classCode,
      this.sectionCode,
      this.subjectCode,
       this.name,
       this.roll,
       this.url,
       this.status,
       this.token,
       this.subjectName});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      students = getAllStudent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'Students List'),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: FutureBuilder<StudentList>(
        future: students,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.students.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.students.length,
                itemBuilder: (context, index) {
                  return SubjectStudentRow(snapshot.data!.students[index],
                      subjectCode: subjectCode,
                      status: status!,
                      token: token!,
                      subjectName: subjectName!);
                },
              );
            } else {
              return Utils.noDataWidget();
            }
          } else {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<StudentList> getAllStudent() async {
    final response = await http.get(Uri.parse(url!),
        headers: Utils.setHeader(token.toString()));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      return StudentList.fromJson(jsonData['data']['students']);
    } else {
      throw Exception('Failed to load');
    }
  }
}
