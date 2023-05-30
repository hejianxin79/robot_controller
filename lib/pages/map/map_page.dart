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
  Offset localPosition = const Offset(-1, -1);
  Color color = const Color(0x00000000);
  Color c = Color(0x000000);
  Offset p = const Offset(-1, -1);
  bool is_show_msg = true;
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
    if(this.c != this.color){
      setState(() {
        this.c = this.color;
      });
    }
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

                    setState(() {
                      if (localPosition != this.p){

                        this.color = color;
                        _getTapPosition(context);
                      }
                      //print(color);

                    });

                  }
                });
                return Stack(
                  children: [
                    const Image(
                      width: 384,
                      height: 384,
                      //fit: BoxFit.contain,
                      image: AssetImage("images/map.jpg"),
                    ),
                    Positioned(
                      left: localPosition.dx - 10,
                      top: localPosition.dy - 10,
                      child: const Image(
                        width: 20,
                        height: 20,
                        image: AssetImage("images/direction.png"),
                      ),
                    ),
                  ],
                );
              }
          ),

        )
    );

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
              padding: EdgeInsets.only(left: 10),
              child: Text("去邀请"),
            ),

          ],
        ));
  }
  Future<Future<int?>> _showBasicModalBottomSheet(context, List<String> options) async {
    return showModalBottomSheet<int>(
      isScrollControlled: false,
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                title: Text(options[index]),
                onTap: () {
                  Navigator.of(context).pop(index);
                });
          },
          itemCount: options.length,
        );
      },
    );
  }
}
