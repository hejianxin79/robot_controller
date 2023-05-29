import 'package:fluro/fluro.dart';
import 'package:robot_controller/pages/index_page.dart';

var IndexHandler = Handler(handlerFunc: (context, Map<String, List<String>> params){
  return const IndexPage();
});