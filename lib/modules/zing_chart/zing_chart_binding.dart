import 'package:get/get.dart';

import 'zing_chart_controller.dart';

class ZingChartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZingChartController>(ZingChartController.new, fenix: true);
  }
}
