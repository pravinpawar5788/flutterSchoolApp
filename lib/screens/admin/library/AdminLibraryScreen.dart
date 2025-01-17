import 'package:flutter/material.dart';

// Project imports:
import 'package:infixedu/utils/CardItem.dart';
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/FunctinsData.dart';

// ignore: must_be_immutable
class AdminLibraryHome extends StatefulWidget {
  final _titles;
  final _images;
  dynamic id;
  String? profileImage;

  AdminLibraryHome(this._titles, this._images, {Key? key}) : super(key: key);

  @override
  _AdminLibraryHomeState createState() =>
      _AdminLibraryHomeState(_titles, _images);
}

class _AdminLibraryHomeState extends State<AdminLibraryHome> {
  bool? isTapped;
  dynamic currentSelectedIndex;
  // ignore: prefer_typing_uninitialized_variables
  final _titles;
  // ignore: prefer_typing_uninitialized_variables
  final _images;

  _AdminLibraryHomeState(this._titles, this._images);

  @override
  void initState() {
    super.initState();
    isTapped = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'Library',
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.builder(
          itemCount: _titles.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, index) {
            return CustomWidget(
              index: index,
              isSelected: currentSelectedIndex == index,
              onSelect: () {
                setState(() {
                  currentSelectedIndex = index;
                  AppFunction.getAdminLibraryPage(context, _titles[index]);
                });
              },
              headline: _titles[index],
              icon: _images[index],
            );
          },
        ),
      ),
    );
  }
}
