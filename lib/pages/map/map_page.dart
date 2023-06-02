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
  //点位名称输入框
  final TextEditingController _markTextEditingController = TextEditingController();
  //输入的点位名称
  final String _makeName = "";
  //点击地图后记录点击位置在地图上的像素位置
  Offset localPosition = const Offset(-1, -1);
  //点击地图后获取像素颜色
  Color color = const Color(0x00000000);
  //获取当前点击像素颜色
  Color c = const Color(0x00000000);
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
      resizeToAvoidBottomInset: false,
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
    if(this.color == const Color(0xffdcdcdc) || this.color == Color(0xffcdcdcd)){
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
                    //TODO::这里有BUG，第一次点击地图未保存，会循环触发这里，需要解决
                    if(offsetList.length==0 && localPosition.dx.toInt() > 0){
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
  /// 底部弹窗
  Future<Future<int?>> _showBasicModalBottomSheet(context, List<String> options) async {
    return showModalBottomSheet<int>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(10.h),
          height: 200.h,
          color: Colors.white,
          child: Column(
            children: [

              TextField(
                controller: _markTextEditingController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: "请输入点位名称",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 5,
                      style: BorderStyle.none, // 隐藏边框
                    ),
                  ),
                ),

              ),
              SizedBox(
                height: 73.h,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      print("点击了取消按钮");

                      print(offsetList);
                      print(markList);
                      print("markList.length***************** "+markList.length.toString());
                      print("offsetList.length################### "+offsetList.length.toString());
                      if(markList.length > 1){
                        markList.removeAt(markList.length-1);
                        offsetList.removeAt(offsetList.length-1);
                      }
                      Navigator.pop(context);

                    },
                    child: Container(
                      width: 150.w,
                      height: 50.h,

                      decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.all(Radius.circular(10.h))
                      ),
                      child: Center(
                        child: Text(
                          "取   消",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 55.w,
                  ),
                  InkWell(
                    onTap: (){
                      print("点击了保存按钮");
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 150.w,
                      height: 50.h,

                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(10.h))
                      ),
                      child: Center(
                        child: Text(
                          "保   存",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


}
