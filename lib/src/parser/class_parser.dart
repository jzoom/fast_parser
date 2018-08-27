

import 'package:fast_parser/fast_parser.dart';

class ClassParser extends Context{
  int pairCount = 0;
  final bool isAbstract;
  final List<Annotation> annotations;
  ClassParser(this.isAbstract,this.annotations);

  Class parse(LineStream stream) {

    //print(firstLine);
    Match match = stream.readRegExp(classRegExp);
    if(match==null){
      throw new Exception("Unexpected class " + stream.peekString());
    }
    String className = match.group(1);
    print("Get class:$className");
    // parse the body
    // stream.skipLine();


    parseUntilEnd(stream);

    return new Class(
        name: className,
        isAbstract: isAbstract,
        methods: cachedMethod,
        fields: cachedField,
        annotations:annotations

    );
  }

  void parseUntilEnd(LineStream stream){
    while(stream.hasNextString()){
      String line = stream.peekString();
      if(parseLine(stream,line)){
        continue;
      }
      if(line.startsWith("}")){
        stream.skip(1);
        //end of class
        print("End of class");
        return;
      }
      stream.skipLine();
    }
  }
}