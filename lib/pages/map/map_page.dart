import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_pixels/image_pixels.dart';

import '../../utils/toast.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //点击地图后记录点击位置在地图上的像素位置
  Offset localPosition = const Offset(-1, -1);
  //点击地图后获取像素颜色
  Color color = const Color(0x00000000);
  //获取当前点击像素颜色
  Color c = Color(0x000000);
  //获取当前点击地图像素位置
  Offset p = const Offset(-1, -1);
  bool is_show_msg = true;
  //坐标视图位置列表。
  List<Widget> markList = [
    const Image(
      width: 384,
      height: 384,
      //fit: BoxFit.contain,
      image: AssetImage("images/map.jpg"),
    ),
  ];
  //坐标位置列表
  List<Offset> offsetList = [];
  Future<void> socketUtil(BuildContext context,String host, int port,String params) async {
    try {
      var socket = await Socket.connect(host, port);
      socket.writeln(params);
      socket.writeln();
      await socket.flush();
      socket.listen((event) {
        print(utf8.decode(event).toString());
      });
      socket.close();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("地图"),
        elevation: 0.1,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
        child: mapView2(context),
      ),
    );
  }
  void _getTapPosition(BuildContext context) async{
    //判断是否点击了同一个位置。
    if(this.c != this.color){
      setState(() {
        this.c = this.color;
      });
    }
    //判断是否点击了同一个位置。
    if(this.p != this.localPosition){
      setState(() {
        this.p = this.localPosition;
      });
    }
    sleep(const Duration(milliseconds:500));
    //showBottomSheet(context);
    List<String> par = [
      "1",
      "2"
    ];

    print(color);
    if(this.color == Color(0xffdcdcdc) || this.color == Color(0xffcdcdcd)){
      Toast.toast(context,msg: "所选位置机器人可能无法到达",showTime: 1500);
    }else{
      int count = markList.length + 1;
      setState(() {
        markList.add(
          Positioned(
            left: localPosition.dx - 10,
            top: localPosition.dy - 10,
            child: InkWell(
              onTap: (){
                print(count.toString());
              },
              child: Container(
                width: 30,
                height: 30,
                color: Colors.blue,
                child: const Image(
                  width: 20,
                  height: 20,
                  image: AssetImage("images/mark.png"),
                ),
              ),
            ),
          ),
        );
        offsetList.add(localPosition);
      });
      _showBasicModalBottomSheet(context,par);
    }

    //socketUtil(context,'192.168.0.80', 9999, '{"method":"moveMapPoint","x":$dx,"y":$dy,"metre":false}');
  }
  Widget mapView2(BuildContext context){

    return Container(
        color: Colors.grey,

        child: Listener(

          onPointerDown: (PointerDownEvent details) {

            setState(() {
              localPosition = details.localPosition;
            });
          },
          child: ImagePixels(
              imageProvider: const AssetImage("images/map.jpg"),
              builder: (BuildContext context, ImgDetails img) {
                var color = img.pixelColorAt!(
                  localPosition.dx.toInt(),
                  localPosition.dy.toInt(),
                );
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  if (mounted) {
                    //判断坐标列表里是否存在点击的坐标范围
                    //bool is_offset = _offsetRange(localPosition);
                    if(offsetList.length==0){
                      setState(() {
                        this.color = color;
                        _getTapPosition(context);
                      });
                    }else {
                      if (_offsetRange(context,localPosition) == false) {
                        //判断本次点击是否在上次点击的安全范围之外x
                        int a = localPosition.dx.toInt() - this.p.dx.toInt();
                        //判断本次点击是否在上次点击的安全范围之外y
                        int b = localPosition.dy.toInt() - this.p.dy.toInt();
                        if (localPosition != this.p) {
                          if ((a <= -20 || a >= 20) || (b <= -20 || b >= 20)) {
                            setState(() {
                              this.color = color;
                              _getTapPosition(context);
                            });
                          }
                        }
                      }
                    }
                  }
                });
                return Stack(
                  children: markList,
                );
              }
          ),

        )
    );

  }
  /*
  //循环当前点为列表，判断当前点击的点为坐标是否与列表内坐标距离过近
   */
  bool _offsetRange(BuildContext context, Offset loc){
    //记录与当前点击的坐标过近的数量
    int ab = 0;
    for(Offset of in offsetList){
      //判断本次点击是否在上次点击的安全范围之外x
      int a = loc.dx.toInt() - of.dx.toInt();
      //判断本次点击是否在上次点击的安全范围之外y
      int b = loc.dy.toInt() - of.dy.toInt();
      //范围为+-20像素以上
      if((a<=-20 || a>=20) || (b<=-20 || b>=20)){

      }else{
        ab += 1;
      }
    }
    //如果列表内不存在过近点为则返回false
    if(ab == 0){
      return false;
    }
    return true;

  }

  void showBottomSheet(BuildContext context) {
    //用于在底部打开弹框的效果
    showModalBottomSheet(
        builder: (BuildContext context) {
          //构建弹框中的内容
          return buildBottomSheetWidget(context);
        },
        backgroundColor: Colors.transparent,//重要
        context: context);
  }
  ///底部弹出框的内容
  Widget buildBottomSheetWidget(BuildContext context) {
    return Container(
        height: 250.h,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        child: Column(
          children: [
            Text(
              "邀请好友",
              style: TextStyle(
                color: Color(0xFF36393D),
                fontSize: 46.w,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 10),
              child: const Text("去邀请"),
            ),

          ],
        ));
  }
  Future<Future<int?>> _showBasicModalBottomSheet(context, List<String> options) async {
    return showModalBottomSheet<int>(
      isScrollControlled: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          color: Colors.red,
          child: const Column(
            children: [
              //TextField(),
            ],
          ),
        );
      },
    );
  }


}
