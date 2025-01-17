// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/screens/fees/controller/student_fees_controller.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/screens/fees/paymentGateway/khalti/sdk/khalti.dart';

import '../khalti/core/khalti_core.dart';

class KhaltiInvoicePayment extends StatelessWidget {
  final String? email;
  final String method;
  final String amount;
  final String? transactionId;

  const KhaltiInvoicePayment({Key? key,
     this.email,
    required this.method,
    required this.amount,
    this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _tabs = [
      const Tab(text: 'Wallet Payment'),
      const Tab(text: 'EBanking'),
      const Tab(text: 'MBanking'),
    ];

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConfig.appToolbarBackground),
                fit: BoxFit.fill,
              ),
              color: Colors.deepPurple,
            ),
          ),
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    height: 70.h,
                    child: IconButton(
                        tooltip: 'Back',
                        icon: Icon(
                          Icons.arrow_back,
                          size: ScreenUtil().setSp(20),
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Text(
                      "Khalti Payment",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: ScreenUtil().setSp(20),
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelPadding: EdgeInsets.zero,
            tabs: _tabs,
          ),
        ),
        body: TabBarView(
          children: [
            WalletPayment(
              email: email!,
              method: method,
              amount: amount,
              transactionId: transactionId!,
            ),
            Banking(
                email: email!,
                method: method,
                amount: amount,
                transactionId: transactionId!,
                paymentType: BankPaymentType.eBanking),
            Banking(
                email: email!,
                method: method,
                amount: amount,
                paymentType: BankPaymentType.mobileCheckout, transactionId: '',),
          ],
        ),
      ),
    );
  }
}

class WalletPayment extends StatefulWidget {
  final String email;
  final String method;
  final String amount;
  final String transactionId;

  const WalletPayment({Key? key,
    required this.email,
    required this.method,
    required this.amount,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<WalletPayment> createState() => _WalletPaymentState();
}

class _WalletPaymentState extends State<WalletPayment> {
  late TextEditingController _mobileController, _pinController;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            validator: (v) => (v?.isEmpty ?? true) ? 'Required ' : null,
            decoration: const InputDecoration(
              label: Text('Mobile Number'),
            ),
            controller: _mobileController,
          ),
          TextFormField(
            validator: (v) => (v?.isEmpty ?? true) ? 'Required ' : null,
            decoration: const InputDecoration(
              label: Text('Khalti MPIN'),
            ),
            controller: _pinController,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            onPressed: () async {
              if (!(_formKey.currentState?.validate() ?? false)) return;

              try {
                final initiationModel = await Khalti.service.initiatePayment(
                  request: PaymentInitiationRequestModel(
                    amount:
                        double.parse(widget.amount.toString()).toInt() * 100,
                    mobile: _mobileController.text,
                    productIdentity: widget.method,
                    productName: widget.method,
                    transactionPin: _pinController.text,
                    productUrl: '',
                  ),
                );

                final otpCode = await showDialog<String>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    String? _otp;
                    return AlertDialog(
                      title: const Text('OTP Sent!'),
                      content: TextField(
                        decoration: const InputDecoration(
                          label: Text('OTP Code'),
                        ),
                        onChanged: (v) => _otp = v,
                      ),
                      actions: [
                        SimpleDialogOption(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context, _otp),
                        )
                      ],
                    );
                  },
                );

                print("OTP CODE $otpCode");
                if (otpCode != null) {
                  final model = await Khalti.service.confirmPayment(
                    request: PaymentConfirmationRequestModel(
                      confirmationCode: otpCode,
                      token: initiationModel.token,
                      transactionPin: _pinController.text,
                    ),
                  );
                  print(model);

                  Map params = {"token": model.token, "amount": model.amount};

                  var response = await http.post(
                    Uri.parse(
                      "https://khalti.com/api/v2/payment/status/",
                    ),
                    headers: {
                      "Authorization": "Key $khaltiPublicKey",
                    },
                    body: jsonEncode(params),
                  );
                  Utils.showToast(response.body.toString());
                  Utils.showToast(response.statusCode.toString());
                  var jsonString = jsonDecode(response.body);
                  Utils.showToast(jsonString.toString());
                  if (response.statusCode == 200) {
                    if (jsonString['state'] == "Complete") {
                      Utils.showToast("Payment state: ${jsonString['state']}");

                      final StudentFeesController _studentFeesController =
                          Get.put(StudentFeesController());

                      await _studentFeesController.confirmPaymentCallBack(
                          widget.transactionId.toString());
                    }
                  } else {
                    Utils.showToast(
                        'Unable to pay ${response.body.toString()}');
                  }
                }
              } catch (e) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text('PAY Rs. ${widget.amount}'),
          ),
        ],
      ),
    );
  }
}

class Banking extends StatefulWidget {
  final String email;
  final String method;
  final String amount;
  final String transactionId;
  final BankPaymentType paymentType;

  const Banking(
      {Key? key, required this.email,
      required this.method,
      required this.amount,
      required this.transactionId,
      required this.paymentType}) : super(key: key);

  @override
  State<Banking> createState() => _BankingState();
}

class _BankingState extends State<Banking> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<BankListModel>(
      future: Khalti.service.getBanks(paymentType: widget.paymentType),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final banks = snapshot.data?.banks;
          return ListView.builder(
            itemCount: banks?.length,
            itemBuilder: (context, index) {
              final bank = banks?[index];
              return ListTile(
                leading: SizedBox.square(
                  dimension: 40,
                  child: Image.network(bank!.logo),
                ),
                title: Text(bank!.name),
                subtitle: Text(
                  bank!.shortName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                onTap: () async {
                  final mobile = await showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      String? _mobile;
                      return AlertDialog(
                        title: const Text('Enter Mobile Number'),
                        content: TextField(
                          decoration: const InputDecoration(
                            label: Text('Mobile Number'),
                          ),
                          onChanged: (v) => _mobile = v,
                        ),
                        actions: [
                          SimpleDialogOption(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context, _mobile),
                          )
                        ],
                      );
                    },
                  );

                  if (mobile != null) {
                    // ignore: unused_local_variable
                    final url = Khalti.service.buildBankUrl(
                      bankId: bank.idx,
                      amount:
                          double.parse(widget.amount.toString()).toInt() * 100,
                      mobile: mobile,
                      productIdentity: widget.method,
                      productName: widget.method,
                      paymentType: widget.paymentType,
                      returnUrl: AppConfig.domainName,
                    );
                  }
                },
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
