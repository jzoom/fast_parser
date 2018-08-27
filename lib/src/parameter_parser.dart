
import 'package:fast_parser/fast_parser.dart';
import 'package:fast_parser/src/method.dart';

class ParameterParser extends  Context{

  ParameterParser();


  Map<String,ParameterInfo> readNamedParameterInfo(LineStream stream){
    Map<String,ParameterInfo> map = {};
    print("Parse named parameters");
    List<Annotation> annotations = [];
    while(stream.hasNextString()){
      String line = stream.peekString();
      //print(line);
      if(skipComments(stream, line)){
        continue;
      }

      if(line.startsWith(",")){
        stream.skip(1);
        continue;
      }

      if(line.startsWith("@")){
        annotations.add(stream.readAnnotation());
        continue;
      }

      if(line.startsWith(":")){
        //parse value
        stream.skip(1);

        // "xxx"
        // 1
        // 1.0
        // bool|false
        // abc
        String symbo = stream.skipUntilOr([",","}"]);
        if(symbo=="}"){
          return map;
        }

        continue;
      }

      if(line.startsWith("}")){
        stream.skip(1);
        print("End of named parameter");
        break;
      }

      Match match = stream.readRegExp(methodParamExp);
      if(match!=null){
        stream.readMethod([]);
        //
        continue;
      }

      match = stream.readRegExp(paramWithTypeExp);
      if(match!=null){
        String type = match.group(1);
        String name = match.group(2);
        print("Get argument : name:$name type:$type");
        map[name] = (new ParameterInfo(
            name: name,
            type: type,
          annotations: annotations
        ));
        annotations = [];
        continue;
      }

      match = stream.readRegExp(paramExp);
      if(match!=null){
        String type = match.group(1);
        String name = match.group(2);
        print("Get argument : name:$name type:$type");
        map[name] = (new ParameterInfo(
            name: name,
            type: type,
          annotations: annotations
        ));
        annotations = [];
        continue;
      }

      match = stream.readRegExp(noParamExp);
      if(match!=null){
        String type = 'dynamic';
        String name = match.group(1);
        print("Get argument : name:$name type:$type");
        map[name] = (new ParameterInfo(
            name: name,
            type: type,
          annotations: annotations
        ));
        annotations = [];
        continue;
      }

      stream.skipLine();
    }
    return map;
  }

  Parameter parse(LineStream stream) {
    List<Annotation> annotations = [];
    Parameter parameter = new Parameter();
    while(stream.hasNextString()){
      String line = stream.peekString();
      //print(line);
      if(skipComments(stream, line)){
        continue;
      }

      if(line.startsWith(",")){
        stream.skip(1);
        continue;
      }

      if(line.startsWith(")")){
        stream.skip(1);
        print("End of parameter");
        return parameter;
      }

      if(line.startsWith("{")){
        //Named parameter
        stream.skip(1);
        parameter.named.addAll(readNamedParameterInfo(stream));
        return parameter;
      }

      /// int a
      /// a
      /// Map<String, String> map
      /// void test()
      ///
      if(line.startsWith("@")){
        annotations.add(stream.readAnnotation());
        continue;
      }


      Match match = stream.readRegExp(methodParamExp);
      if(match!=null){
        stream.readMethod([]);
        //
        continue;
      }

      match = stream.readRegExp(paramWithTypeExp);
      if(match!=null){
        String type = match.group(1);
        String name = match.group(2);
        print("Get argument : name:$name type:$type");
        parameter.ordered.add(new ParameterInfo(
            name: name,
            type: type,
            annotations: annotations ,
        ));
        annotations = [];
        continue;
      }

      match = stream.readRegExp(paramExp);
      if(match!=null){
        String type = match.group(1);
        String name = match.group(2);
        print("Get argument : name:$name type:$type");
        parameter.ordered.add(new ParameterInfo(
            name: name,
            type: type,
            annotations:annotations
        ));
        annotations = [];
        continue;
      }

      match = stream.readRegExp(noParamExp);
      if(match!=null){
        String type = 'dynamic';
        String name = match.group(1);
        print("Get argument : name:$name type:$type");
        parameter.ordered.add(new ParameterInfo(
            name: name,
            type: type,
          annotations:annotations,
        ));
        annotations = [];
        continue;
      }

      stream.skipLine();

    }
    return parameter;
  }

}



RegExp paramWithTypeExp = new RegExp(r"([a-zA-Z0-9$_]+<[^>]+>)[\s]+([a-zA-Z0-9$_]+)");
RegExp paramExp = new RegExp(r"([a-zA-Z0-9$_]+)[\s]+([a-zA-Z0-9$_]+)");
RegExp noParamExp = new RegExp(r"([a-zA-Z0-9$_]+)");
RegExp methodParamExp = methodExp;

