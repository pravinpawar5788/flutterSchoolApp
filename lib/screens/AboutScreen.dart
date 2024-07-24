import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

// Project imports:
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/AboutSchool.dart';
import 'package:infixedu/utils/server/About.dart';

// ignore: must_be_immutable
class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  About about = About();

  String? _token;

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      setState(() {
        _token = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'About',
      ),
      backgroundColor: Colors.white,
      body: getAboutList(context),
    );
  }

  Widget getAboutList(BuildContext context) {
    return FutureBuilder<AboutData>(
      future: about.fetchAboutServices(_token!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CachedNetworkImage(
                    height: 50.h,
                    width: 100.w,
                    imageUrl: InfixApi.root + snapshot.data!.logo!,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl:
                          InfixApi.root + 'public/uploads/staff/demo/staff.jpg',
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  title: Text(
                    snapshot.data!.schoolName!,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: ScreenUtil().setSp(15),
                        color: Colors.deepPurple),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  snapshot.data!.mainDescription!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: ScreenUtil().setSp(15),
                      color: Colors.deepPurple),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Address".tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    Expanded(
                      child: Text(snapshot.data?.address ?? "N/A",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Phone".tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    Expanded(
                      child: Text(snapshot.data?.phone ?? "N/A",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email".tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    Expanded(
                      child: Text(snapshot.data?.email ?? "N/A",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
      },
    );

    // return FutureBuilder<List<InfixMap>>(
    //   future: about.fetchAboutServices(_token,_schoolId),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Column(
    //           children: <Widget>[
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Text(
    //                 '${snapshot.data[0].value}',
    //                 style: Theme.of(context)
    //                     .textTheme
    //                     .headlineMedium
    //                     .copyWith(fontSize: ScreenUtil().setSp(15), color: Colors.deepPurple),
    //               ),
    //             ),
    //             Expanded(
    //               child: ListView.builder(
    //                 itemCount: snapshot.data.length - 1,
    //                 itemBuilder: (context, index) {
    //                   return ProfileRowList(snapshot.data[index + 1].key,
    //                       snapshot.data[index + 1].value);
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     } else {
    //       return Center(
    //         child: CupertinoActivityIndicator(),
    //       );
    //     }
    //   },
    // );
  }
}
