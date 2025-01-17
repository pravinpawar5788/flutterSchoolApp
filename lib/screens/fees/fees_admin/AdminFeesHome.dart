// Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infixedu/controller/system_controller.dart';

// Project imports:
import 'package:infixedu/utils/CardItem.dart';
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/FunctinsData.dart';

// ignore: must_be_immutable
class AdminFeesHome extends StatefulWidget {
  final _titles;
  final _images;
  dynamic id;
  String? profileImage;

  AdminFeesHome( this._titles, this._images, {Key? key}) : super(key: key);

  @override
  _AdminFeesHomeState createState() => _AdminFeesHomeState(_titles, _images);
}

class _AdminFeesHomeState extends State<AdminFeesHome> {
  bool? isTapped;
  dynamic currentSelectedIndex;
  final _titles;
  final _images;

  _AdminFeesHomeState(this._titles, this._images);

  final SystemController _systemController = Get.put(SystemController());

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
                  if (_systemController.systemSettings.value.data?.feesStatus ==
                      0) {
                    AppFunction.getAdminFeePage(context, _titles[index]);
                  } else {
                    AppFunction.getAdminFeePageNew(context, _titles[index]);
                  }
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
