import 'package:get/get.dart';

class GlobalValueController extends GetxController{
  var screenHeight = 0.0.obs;
  var screenWidth = 0.0.obs;

  void updateScreenHeight(double screenHeight){
    this.screenHeight.value = screenHeight;
    update();
  }

  void updateScreenWidth(double screenWidth){
    this.screenWidth.value = screenWidth;
    update();
  }
}