import 'package:get/get.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/model/SystemSettings.dart';
import 'package:http/http.dart' as http;

class SystemController extends GetxController {
  Rx<SystemSettings> systemSettings = SystemSettings().obs;
  Rx<bool> isLoading = false.obs;

  final Rx<String> _token = "".obs;

  Rx<String> get token => _token;

  final Rx<String> _schoolId = "".obs;

  Rx<String> get schoolId => _schoolId;

  Future getSystemSettings() async {
    try {
      isLoading(true);
      await getSchoolId().then((value) async {
        final response = await http.get(
            Uri.parse(InfixApi.generalSettings + '/$schoolId'),
            headers: Utils.setHeader(_token.toString()));
        print("Hello>>>>>>>");
        print(response.body);
        if (response.statusCode == 200) {

          final studentRecords = systemSettingsFromJson(response.body);
          systemSettings.value = studentRecords;

          isLoading(false);
        } else {
          isLoading(false);
          throw Exception('failed to load');
        }
      });
    } catch (e, t) {
      isLoading(false);
      print('From e: $e');
      print('From t: $t');
      throw Exception('failed to load');
    }
  }

  Future getSchoolId() async {
    await Utils.getStringValue('schoolId').then((value) async {
      _schoolId.value = value!;
      await Utils.getStringValue('token').then((value) async {
        _token.value = value!;
      });
    });
  }

  @override
  void onInit() {
    getSystemSettings();
    super.onInit();
  }
}
