import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:robot_controller/routers/router_handler.dart';

class Routes{
  static String index = "/index";

  static void configureRoutes(FluroRouter router){
    router.notFoundHandler = Handler(handlerFunc: (context, Map<String, List<String>> params){
      debugPrint("未找到相应路由地址");
    });
    router.define(index, handler: IndexHandler);
  }

}