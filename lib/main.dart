import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:robot_controller/pages/index_page.dart';
import 'package:robot_controller/provider/bottom_nav_provider.dart';
import 'package:robot_controller/routers/application.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  final routers = FluroRouter();
  Application.routers = routers;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>BottomNavProvider()),
      ],
      child: const RobotControllerApp(),
    )
  );
}

class RobotControllerApp extends StatelessWidget {
  const RobotControllerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 819),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          color: const Color(0xFFF7F7F7),
          theme: ThemeData(highlightColor: Colors.white, splashColor: Colors.white),
          home: const IndexPage(),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
