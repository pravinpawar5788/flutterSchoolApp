// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:infixedu/utils/CardItem.dart';
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/FunctinsData.dart';

// ignore: must_be_immutable
class AdminFeesReportMain extends StatefulWidget {
  final _titles;
  final _images;

  const AdminFeesReportMain(this._titles, this._images, {Key? key}) : super(key: key);

  @override
  _AdminFeesReportMainState createState() =>
      _AdminFeesReportMainState(_titles, _images);
}

class _AdminFeesReportMainState extends State<AdminFeesReportMain> {
  bool? isTapped;
  dynamic currentSelectedIndex;
  final _titles;
  final _images;

  _AdminFeesReportMainState(this._titles, this._images);

  @override
  void initState() {
    super.initState();
    isTapped = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'Fees',
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
                  AppFunction.getAdminFeesReportPage(context, _titles[index]);
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
