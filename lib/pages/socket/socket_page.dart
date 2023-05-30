import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '';
class SocketPage extends StatefulWidget {
  const SocketPage({Key? key}) : super(key: key);

  @override
  State<SocketPage> createState() => _SocketPageState();
}

class _SocketPageState extends State<SocketPage> {
  late String msgData = "11111";
  Future<void> socketUtil(BuildContext context,String host, int port,String params) async{
    try{
      var socket = await Socket.connect(host, port);
      socket.writeln(params);
      socket.writeln();
      await socket.flush();
      socket.listen((event) {
        String msg = utf8.decode(event).toString();
        debugPrint(msg);
        setState(() {
          msgData = msg;
        });
      });
      socket.close();
    }catch(e){
      debugPrint(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Socket测试",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
        elevation: 0.01,
      ),
      body: socketView(context),
    );
  }

  Widget socketView(BuildContext context){
    return Column(
      children: [
        msgView(context),
        socketButtonView(context),
      ],
    );
  }

  Widget msgView(BuildContext context){
    return Container(
      padding: EdgeInsets.all(5.w),
      width: 375.w,
      height: 120.h,
      color: Colors.black87,
      child: Text(
        "返回信息为:$msgData",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget socketButtonView(BuildContext context){
    return Container(
      height: 518.h,
      child: GridView.count(
        //设置滚动方向
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: false,
        //设置列数
        crossAxisCount: 3,
        //设置内边距
        padding: const EdgeInsets.all(5),
        //设置横向间距
        crossAxisSpacing: 10,
        //设置主轴间距
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: [
          InkWell(
            onTap: (){
              debugPrint("点击了获取机器人坐标按钮");
            },
            child: Container(
              alignment: Alignment.center,
              decoration:const BoxDecoration(
                //背景
                color: Colors.blue,
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Text(
                "获取机器人坐标",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: (){
              debugPrint("点击了pgm转jpg按钮");
              socketUtil(context, "192.168.0.101", 9999, '{"method":"pgmToJpg"}');
            },
            child: Container(
              alignment: Alignment.center,
              decoration:const BoxDecoration(
                //背景
                color: Colors.blue,
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Text(
                "pgm转jpg",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],

      ),
    );
  }
}
