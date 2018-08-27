

import 'package:fast_parser/fast_parser.dart';
import 'package:fast_parser/src/type.dart';

class ParameterInfo{
  String name;
  String type;
  List<Annotation> annotations;

  ParameterInfo({
    this.name,
    this.type,
    this.annotations
});

  @override
  String toString() {
    StringBuffer s  = new StringBuffer();

    annotations.forEach((Annotation an){
      s.write(an.toString());
      s.write("\n");
    });

    s.write(type);
    s.write(" ");
    s.write(name);

    return s.toString();
  }



}

class Parameter{

  List<ParameterInfo> ordered = [];
  Map<String,ParameterInfo> named = {};


  Parameter();
}



///
/// Info about Closure
///
class Method extends Parameter{

  bool isStatic;
  String name;
  final ParsedType returnType;

  List<ParameterInfo> ordered;
  Map<String,ParameterInfo> named;
  List<Annotation> annotations;
  final bool isAbstract;

  Method({
    this.name,
    this.isStatic,
    this.ordered,
    this.named,
    this.returnType,
    this.annotations,
    this.isAbstract
});


  @override
  String toString() {

    StringBuffer s  = new StringBuffer();

    annotations.forEach((Annotation an){
      s.write(an);
      s.write("\n");
    });

    s.write(returnType);
    s.write(" ");
    s.write(name);
    s.write("(");

    bool first = true;

    ordered.forEach((ParameterInfo info){
      if(first){
        first = false;
      }else{
        s.write(",");
      }
      s.write(info);
    });

    if(ordered.length>0){
      s.write(",");
    }

    if(named.length > 0){
      first = true;
      s.write("{\n");
      named.forEach( (String key ,ParameterInfo value){
        if(first){
          first = false;
        }else{
          s.write(",");
        }
        s.write(value);

      });
      s.write("}\n");
    }


    s.write(")");

    if(isAbstract){
      s.write(";");
    }else{
      s.write("{}");
    }

    return s.toString();
  }


}