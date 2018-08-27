

import 'package:fast_parser/src/annotation.dart';

class Field{

  bool isStatic;
  String name;
  String type;
  bool isFinal;
  bool isConst;

  List<Annotation> annotations;


  Field({
    this.isStatic,
    this.name,
    this.type,
    this.isConst,
    this.isFinal,
    this.annotations
});

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();

    if(isStatic){
      sb.write("static ");
    }

    if(isFinal){
      sb.write("final ");
    }

    if(isConst){
      sb.write("const ");
    }

    sb.write(type);
    sb.write(" ");
    sb.write(name);
    sb.write(";");

    return sb.toString();
  }

}