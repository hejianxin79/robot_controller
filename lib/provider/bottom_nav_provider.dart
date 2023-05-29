import 'package:flutter/material.dart';

class BottomNavProvider with ChangeNotifier{
  int bottomIndex = 0;
  void changeBottomIndex(int index){
    if(bottomIndex != index){
      bottomIndex = index;
    }
    notifyListeners();
  }
}