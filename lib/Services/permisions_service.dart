import 'package:permission_handler/permission_handler.dart';

class permisions{
  Future<void> getnotificationpermision()async{
    final permision = await Permission.notification.request();
    if(permision.isGranted){
      print('permision granted');
    }else{
      print('permision not granted');
    }
  }
}