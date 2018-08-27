


import 'package:fast_parser/fast_parser.dart';
import 'package:fast_parser/src/field.dart';
import 'package:fast_parser/src/method.dart';
import 'package:fast_parser/src/util.dart';

class Class{

  List<Method> methods;
  List<Field> fields;
  bool isAbstract;
  String name;
  List<Annotation> annotations;

  Class({
    this.name,
    this.isAbstract,
    this.fields,
    this.methods,
    this.annotations
});

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    annotations.forEach((Annotation annotation){
      sb.write(annotation);
      sb.write("\n");
    });
    if(isAbstract){
      sb.write("abstract ");
    }
    sb.write(name);
    sb.write("{\n");

    fields.forEach((f){
      sb..write("  ")..write(f)..write("\n");
    });

    if(fields.length>0){
      sb.write("\n");
    }

    methods.forEach((m){
      sb..write(Util.indent(m.toString()).join("\n"))..write("\n");
    });


    sb.write("}");

    return sb.toString();
  }
}