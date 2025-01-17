// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:infixedu/utils/model/Book.dart';

// ignore: must_be_immutable
class BookListRow extends StatefulWidget {
  Book book;

  BookListRow(this.book, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _BookListRowState createState() => _BookListRowState(book);
}

class _BookListRowState extends State<BookListRow>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation parentAnimation, childAnimation;
  late Book book;

  _BookListRowState(this.book);

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    parentAnimation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    childAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, top: 20.0, right: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              book.title!,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              book.price == null
                                  ? " "
                                  : "\$" + book.price.toString(),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        book.categoryName == null || book.categoryName == ''
                            ? Container()
                            : Text(
                          book.categoryName!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: ScreenUtil().setSp(15.0)),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        book.postDate == null || book.postDate == ''
                            ? Container()
                            : Text(
                                'Added ${book.postDate}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        book.author == null || book.author == "" ? Container() : Text.rich(
                          TextSpan(
                            text: 'Author:',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: ScreenUtil().setSp(14.0),
                                decoration: TextDecoration.underline),
                            children: <TextSpan>[
                              TextSpan(
                                text: "  ${book.author}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: ScreenUtil().setSp(14.0)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        book.publication == null || book.publication == "" ? Container() :  Text.rich(
                          TextSpan(
                            text: 'Published by:',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: ScreenUtil().setSp(14.0),
                                decoration: TextDecoration.underline),
                            children: <TextSpan>[
                              TextSpan(
                                text: "  ${book.publication}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: ScreenUtil().setSp(14.0)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          book.details ?? '',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        showAlertDialog(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 5,),
          AnimatedBuilder(
            animation: parentAnimation,
            builder: (context, child) {
              return Container(
                transform: Matrix4.translationValues(
                    parentAnimation.value * width, 0.0, 0.0),
                child: Text(
                  book.title!,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: ScreenUtil().setSp(15.0)),
                  maxLines: 1,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: parentAnimation,
            builder: (context, child) {
              return Container(
                transform: Matrix4.translationValues(
                    parentAnimation.value * width, 0.0, 0.0),
                child: Text.rich(
                  TextSpan(
                    text: book.author == null || book.author == ""
                        ? ''
                        : book.author,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: ScreenUtil().setSp(13.0),
                        ),
                    children: <TextSpan>[
                      TextSpan(
                        text: book.publication == null || book.publication == ""
                            ? ''
                            : ' | ',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: ScreenUtil().setSp(13.0)),
                      ),
                      TextSpan(
                        text: book.publication == null || book.publication == ""
                            ? ''
                            : book.publication,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: ScreenUtil().setSp(13.0)),
                      ),
                    ],
                  ),
                ),

                // Text(
                //   '${book.author} | ${book.publication}',
                //   style: Theme.of(context)
                //       .textTheme
                //       .headlineMedium
                //       .copyWith(fontSize: 13.0),
                // ),
              );
            },
          ),
          AnimatedBuilder(
            animation: parentAnimation,
            builder: (context, child) {
              return Container(
                transform: Matrix4.translationValues(
                    childAnimation.value * width, 0.0, 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Subject',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                book.subjectName! == null || book.subjectName! == "" ? 'N/A' : book.subjectName!,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Book No',
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              book.bookNo! == null || book.bookNo! == "" ? 'N/A' : book.bookNo!,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Quantity',
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              book.quantity == null
                                  ? 'N/A'
                                  : book.quantity.toString(),
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Price',
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              book.price == null
                                  ? 'N/A'
                                  : "\$${book.price.toString()}",
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Rack No',
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              book.reckNo ?? 'not assigned',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            height: 0.5,
            margin: const EdgeInsets.only(top: 10.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.purple, Colors.deepPurple]),
            ),
          ),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }
}
