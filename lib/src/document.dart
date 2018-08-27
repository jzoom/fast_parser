

import 'package:fast_parser/src/class.dart';
import 'package:fast_parser/src/field.dart';
import 'package:fast_parser/src/method.dart';

class Document{
  final String path;
  final List<Class> classes;
  final List<Method> methods;
  final List<Field> fields;

  Document({
    this.path,
    this.methods,
    this.fields,
    this.classes
});

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb..write("Document ")..write(path)..write("\n");


    sb.write("=========variables=========\n");

    fields.forEach((Field f){
      sb.write(f);
      sb.write("\n");
    });


    sb.write("=========methods=========\n");

    methods.forEach((m){
      sb.write(m);
      sb.write("\n");
    });

    sb.write("=========classes=========\n");

    classes.forEach((Class clazz){
      sb.write(clazz);
      sb.write("\n");
    });



    return sb.toString();
  }


}