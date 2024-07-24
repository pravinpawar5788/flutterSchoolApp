// Dart imports:
import 'dart:convert';
import 'dart:core';
import 'dart:core';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/Book.dart';
import 'package:infixedu/utils/widget/BookRowLayout.dart';
import 'package:infixedu/utils/model/StudentRecord.dart';
import '../../../controller/user_controller.dart';
import '../../../utils/StudentRecordWidget.dart';
import '../../../utils/model/Classes.dart';
import '../../../utils/model/Section.dart';
import '../../../utils/model/TeacherSubject.dart';

class EBookListScreen extends StatefulWidget {
  const EBookListScreen({Key? key}) : super(key: key);

  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<EBookListScreen> {
  final UserController _userController = Get.put(UserController());
  dynamic classId;
  dynamic _id;
  dynamic subjectId;
  dynamic sectionId;
  late String _selectedClass;
  late String _selectedSection;
  late String _selectedSubject;
  Future<BookList>? books;
  late Future<ClassList> classesList;
  Future? classes;
  Future<SectionList>? sections;
  Future<TeacherSubjectList>? subjects;
  late TeacherSubjectList subjectList;
  late String _token;

  @override
  void initState() {
    super.initState();
    Utils.getStringValue('token').then((value) {
      setState(() {
        _token = value!;
      });
    }).then((value) {
      setState(() {
        classId =  _userController.selectedRecord.value.classId;
        _id  =  '4';
        sections = getAllSection(int.parse(_id), classId);
        sections?.then((sectionValue) {
          _selectedSection = sectionValue.sections[0].name;
          sectionId = sectionValue.sections[0].id;
          subjects = getAllSubject(int.parse(_id));
          subjects?.then((subVal) {
            setState(() {
              subjectList = subVal;
              subjectId = subVal.subjects[0].subjectId;
              _selectedSubject = subVal.subjects[0].subjectName!;
            });
          });
        });
        //books = getAllBooks();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'Book List'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudentRecordWidget(
              onTap: (Record record) async {
                _userController.selectedRecord.value= record;
                setState(
                  () {
                    books = getAllBooks();
                  },
                );
              },
            ),
            FutureBuilder<SectionList>(
              future: sections,
              builder: (context, secSnap) {
                if (secSnap.hasData) {
                  return getSectionDropdown(secSnap.data!.sections);
                } else {
                  return const Center(child: CupertinoActivityIndicator());
                }
              },
            ),
            const SizedBox(
              height: 5,
            ),
            FutureBuilder<TeacherSubjectList>(
              future: subjects,
              builder: (context, subSnap) {
                if (subSnap.hasData) {
                  return getSubjectDropdown(subSnap.data!.subjects);
                } else {
                  return const Center(child: CupertinoActivityIndicator());
                }
              },
            ),



            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder<BookList>(
                future: books,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.books.isNotEmpty) {
                      return ListView.builder(
                        itemCount: snapshot.data!.books.length,
                        itemBuilder: (context, index) {
                          return BookListRow(snapshot.data!.books[index]);
                        },
                      );
                    } else {
                      return Utils.noDataWidget();
                    }
                  } else {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<SectionList> getAllSection(dynamic id, dynamic classId) async {
    final response = await http.get(
        Uri.parse(InfixApi.getSectionById(id, classId)),
        headers: Utils.setHeader(_token.toString()));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      return SectionList.fromJson(jsonData['data']['teacher_sections']);
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<TeacherSubjectList> getAllSubject(int id) async {
    final response = await http.get(Uri.parse(InfixApi.getTeacherSubject(id)),
        headers: Utils.setHeader(_token.toString()));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return TeacherSubjectList.fromJson(jsonData['data']['subjectsName']);
    } else {
      throw Exception('Failed to load');
    }
  }



  Widget getSectionDropdown(List<Section> sectionlist) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: DropdownButton(
        elevation: 0,
        isExpanded: true,
        items: sectionlist.map((item) {
          return DropdownMenuItem<String>(
            value: item.name,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10),
              child:
              Text(item.name, style: Theme.of(context).textTheme.headlineMedium),
            ),
          );
        }).toList(),
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(fontSize: ScreenUtil().setSp(15.0)),
        onChanged: (value) {
          setState(() {
            _selectedSection = value as String;

            sectionId = getCode(sectionlist, value);
          });
        },
        value: _selectedSection,
      ),
    );
  }

  Widget getSubjectDropdown(List<TeacherSubject> subjectList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: DropdownButton(
        elevation: 0,
        isExpanded: true,
        items: subjectList.map((item) {
          return DropdownMenuItem<String>(
            value: item.subjectName,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10),
              child: Text(
                item.subjectName!,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          );
        }).toList(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 15.0),
        onChanged: (value) {
          setState(() {
            _selectedSubject = value as String;
            subjectId = getSubjectId(subjectList, value);
          });
        },
        value: _selectedSubject,
      ),
    );
  }


  int? getCode<T extends Iterable<Section>?>(T? t, String title) {
    int? code;
    for (var cls in t!) {
      if (cls.name == title) {
        code = cls.id;
        break;
      }
    }
    return code;
  }


  int? getSubjectId<T extends Iterable<TeacherSubject>?>(T? t, String subject) {
    int? code;
    for (var s in t!) {
      if (s.subjectName == subject) {
        code = s.subjectId;
      }
    }
    return code;
  }

  Future<BookList> getAllBooks() async {
    final response = await http.get(Uri.parse(InfixApi.bookList),
        headers: Utils.setHeader(_token.toString()));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      return BookList.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load');
    }
  }
}
