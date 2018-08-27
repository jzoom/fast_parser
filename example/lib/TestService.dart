import 'dart:async';

import 'package:example/get.dart';

//class MyAnnotation{
//  const MyAnnotation();
//}
//
//const MyAnnotation annotation = const MyAnnotation();

class Dog{

  factory Dog.white(){
    return new Dog(name: 'white');
  }

  Dog({
    this.name
});

  void eat(){
  }

  final String name;


}
//
//
//abstract class Service1 {}
//
//@GET("jkfdsf")
//abstract class Service {
//  static const int numger = 1;
//  static final int a = 2;
//  static var b = 3;
//
//  @GET("myvalue",url: ":jfkdsklf")
//  Future<List> service(
//    /// tes
//      @Url("tes url")
//    a,
//
//    /// test
//    int b,
//
//    /// tes
//    Map<String, String> c, {
//
//        @Url("jkfjdlfjdsfjkl3343")
//    double test: 0.0,
//  });
//
//  @annotation
//  Future ss();
//}
//
//test1({int a: 0}) {}
//
//final num2 = 2;
//const num3 = 3;
//
//final num4 = 8;
//
//var test = () {};
//
//var num = 1;
//
//int a = 2;
