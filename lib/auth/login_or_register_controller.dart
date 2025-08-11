import 'package:get/get.dart';


 class LoginOrRegisterController extends GetxController {
   RxBool showLoginPage = true.obs;
   void togglePages(){
     showLoginPage.value = !showLoginPage.value;
     print("fdfdfdfdf");
   }

 }