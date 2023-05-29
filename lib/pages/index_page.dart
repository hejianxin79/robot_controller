import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:robot_controller/pages/home/home_page.dart';
import 'package:robot_controller/pages/map/map_page.dart';
import 'package:robot_controller/pages/setting/setting_page.dart';
import 'package:robot_controller/pages/socket/socket_page.dart';
import 'package:robot_controller/provider/bottom_nav_provider.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Consumer<BottomNavProvider>(builder: (_,bottomProvider,__){
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: bottomProvider.bottomIndex,
          selectedFontSize: 16.sp,
          selectedItemColor: const Color(0xff3e81fc),
          unselectedFontSize: 16.sp,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "地图"),
            BottomNavigationBarItem(icon: Icon(Icons.network_check), label: "Socket"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置"),
          ],
          onTap: (index){
            bottomProvider.changeBottomIndex(index);
          },
        );
      },),
      body: Consumer<BottomNavProvider>(
        builder: (_,bottomProvider,__){
          return IndexedStack(
            index: bottomProvider.bottomIndex,
            children: const [
              HomePage(),
              MapPage(),
              SocketPage(),
              SettingPage()
            ],
          );
        },
      ),
    );
  }
}
