library fast_parser;

import 'dart:io';

import 'dart:math' as math;

import 'package:fast_parser/src/parameter_parser.dart';
import 'package:fast_parser/src/annotation.dart';
import 'package:fast_parser/src/class.dart';
import 'package:fast_parser/src/document.dart';
import 'package:fast_parser/src/field.dart';
import 'package:fast_parser/src/method.dart';
import 'package:fast_parser/src/parser/class_parser.dart';
import 'package:fast_parser/src/type.dart';

export 'src/document.dart';
export 'src/class.dart';
export 'src/annotation.dart';
export 'src/field.dart';
export 'src/method.dart';
export 'src/type.dart';

bool isMethod(String line) {
  return methodExp.hasMatch(line);
}

bool isVariable(String line) {
  return variableExp.hasMatch(line);
}

class LineStream{
  List<String> source;
  int currentLine = 0;
  int pos = 0;
  LineStream(this.source);


  bool hasNextString(){
    return currentLine < source.length;
  }

  String nextString(){
    try{
      return source[currentLine++].substring(pos);
    }finally{
      pos = 0;
    }
  }


  String peekString(){
    if(pos >= source[currentLine].length)return "";
    //trim
    String result = source[currentLine].substring(pos);
    String trim = result.trim();
    int index = result.indexOf(trim);
    pos += index;
    return trim;
  }


  void skip(int n){
    pos += n;
  }


  String skipUntilOr(List<String> symbos){
    StringBuffer sb = new StringBuffer();
    try{
      String symbo;
      while(hasNextString()){
        String line = peekString();
        int index;
        bool find = false;
        for(int i=0 , c = symbos.length; i < c ; ++i){
          symbo = symbos[i];
          index = line.indexOf(symbo);
          if(index >= 0){
            find = true;
            break;
          }
        }

        if(!find){
          sb.write(line);
          skipLine();
        }else{
          if(pos < line.length){
            sb.write(line.substring(pos,index));
          }

          pos += index + symbo.length;
          break;
        }
      }

      return symbo;

    }finally{
      skipped = sb.toString();
    }

  }

  String skipped;

  /// until token shows up
  void skipUntil(String token){
    StringBuffer sb = new StringBuffer();
    try{
      while(hasNextString()){
        String str = peekString();
        int index = str.indexOf(token);
        if(index < 0){
          sb.write(str);
          currentLine ++;
        }else{
          if(str.substring(index+token.length).length == 0){
            currentLine ++;
            sb.write(str);
          }else{
            if(pos < str.length){
              sb.write(str.substring(pos,index));
            }

            pos += index + token.length;
          }
          break;
        }
      }
    }finally{
      skipped = sb.toString();
    }

  }


  String left(){
    StringBuffer sb = new StringBuffer();
    int index = currentLine;
    while(index < source.length){
      if(index == currentLine){
        sb.write( source[index++].substring(pos) );
      }else{
        sb.write( source[index++].trim() );
      }

      sb.write("\n");
    }
    return sb.toString();
  }



  Class readAbstractClass(List<Annotation> annotations) {
    print("Read abstract class");
    return new ClassParser(true,annotations).parse(this);

  }

  Class readClass(List<Annotation> annotations) {
    print("Read class");
    return new ClassParser(false,annotations).parse(this);
  }

  Match readRegExp(RegExp exp){
    String line = peekString();
    Match math = exp.firstMatch(line);
    if(math==null)return null;
    pos += math.end;
    return math;
  }

  Method readMethod(List<Annotation> annotations) {

    Match math = readRegExp(methodExp);
    String name = math.group(2);
    String returnType = math.group(1);
    
    print("Get method : {name:$name,returnType:$returnType}");

    Parameter parameter = new ParameterParser().parse(this);

    String token = skipUntilOr([';','{']);
    bool isAbstract;
    if(token == ';'){
      print("abstract method");
      isAbstract = true;
    }else if(token == '{'){
      print("Method body start");
      skipUntilPair("{","}");
      isAbstract = false;
    }

    return new Method(
      name: name,
      ordered: parameter.ordered,
      named: parameter.named,
      returnType: new ParsedType.parse(returnType),
      annotations:annotations,
      isAbstract:isAbstract
    );
  }


  Annotation readAnnotation() {
    print("Read annotation");

    Match match = readRegExp(classAnnotation);
    if(match!=null){
      String name = match.group(1);
      String params = match.group(2);
      // name : value
      // "xxx"|false|true|1|1.0|other const
      LineStream stream = new LineStream([params]);
      Map<String,dynamic> named = {};
      List orderd = [];
      while(stream.hasNextString()){
        stream.skipUntil(",");
        String part = stream.skipped;
        //orderd.add(parseValue(value));
        match = namedCall.firstMatch(part); // stream.readRegExp(namedCall);
        if(match!=null){
          String paramName = match.group(1).trim();
          String value = part.substring(match.end).trim();
          named[paramName] = parseValue(value);
          continue;
        }

        print("get order param");
        //not named
        orderd.add(parseValue(part));
      }

      print("Get class annotation : {name:$name,ordered:$orderd,named:$named}");

      return new ClassAnnotation(
          name:  name,
          named: named,
        ordered: orderd
      );
    }
    
    match = readRegExp(constAnnotation);
    if(match==null){
      throw new Exception("Invalid annotation : ${peekString()}" );
    }
    String name = match.group(1);
    print("Get const annotation : {name:$name}");
    return new Annotation(name: name);

  }


  /// static const int a
  /// static var a
  /// static final int a
  /// static final a
  /// static const a
  /// final a
  /// const a
  /// final int a
  /// const int a
  Field readVariable(List<Annotation> annotations) {
    print("Read variable");
    String currentStr = peekString().trim();
    Match match = readRegExp(variableExp);

    String type = match.group(1).trim();
    String name = match.group(2).trim();
    bool isStatic = currentStr.startsWith("static");
    bool isFinal;
    bool isConst;
    if(type == 'final' || type == 'var' || type == 'const' || type == 'static'){
      isFinal = type == 'final';
      isConst = type=='const';
      type = 'dynamic';
    }

    print("Get variable :{name:$name,type:$type}");
    skipLine();
    return new Field(
        isStatic:isStatic,
      name: name,
      type: type,
      isConst: isConst,
      isFinal: isFinal,
      annotations: annotations
    );
  }

  void skipLine() {
    currentLine++;
    pos = 0;
  }

  parseValue(String value) {
    if(value == null || value.length==0)
    {
      throw new Exception("Invalid value $value when parse value");
    }

    if(value.startsWith('"') && value.endsWith('"')){
      return value.substring(1,value.length-1);
    }

    if(value == 'true' ){
      return true;
    }

    if(value == "false"){
      return false;
    }


    if(isDouble(value)){
      return double.parse(value);
    }

    if(isInt(value)){
      return int.parse(value);
    }


    return new RefValue(value);

  }

  bool isDouble(String value) {
    return doubleReg.hasMatch(value);
  }

  bool isInt(String value) {
    return intReg.hasMatch(value);
  }

  void skipUntilPair(String leftPair,String rightPair,{int count:1}) {
    while(hasNextString()){
      String line = peekString();
      int index = line.indexOf(leftPair);
      if(index >= 0){
        count++;
        pos += index;
        continue;
      }

      index = line.indexOf(rightPair);
      if(index >=0 ){
        count--;
        pos += index;
        if(count == 0){
          break;
        }
        continue;
      }

      skipLine();
    }
  }

}

class RefValue {
  final String name;
  RefValue(this.name);

  @override
  String toString() {
    return "ref:$name";
  }
}

class Context {
  List<Annotation> cachedAnnotations = [];

  bool skipComments(LineStream stream,String line){
    if(line.startsWith("//")){
      //print("Get comments line $line");
      stream.skipLine();
      return true;
    }

    if(line.startsWith("/*")){
      stream.skipUntil("*/");
      return true;
    }
    return false;
  }

  List<Class> cachedClasses = [];
  List<Method> cachedMethod = [];
  List<Field> cachedField = [];


  bool parseLogic(LineStream stream,String line){
    if(line.startsWith("@")){
      cachedAnnotations.add(stream.readAnnotation());
      return true;
    }

    if(isVariable(line)){
      cachedField.add(stream.readVariable(cachedAnnotations));
      return true;
    }
    if(isMethod(line)){
      cachedMethod.add(stream.readMethod(cachedAnnotations));
      return true;
    }
    return false;
  }


  bool parseLine(LineStream stream,String line){

    if(skipComments(stream, line)){
      return true;
    }

    if(line.startsWith("import ")){
      stream.skipLine();
      return true;
    }
    if(line.startsWith("library ")){
      stream.skipLine();
      return true;
    }
    if(line.startsWith("export ")){
      stream.skipLine();
      return true;
    }


    if(parseClass(stream,line)){
      return true;
    }



    return parseLogic(stream, line);
  }

  bool parseClass(LineStream stream, String line) {
    if(line.startsWith("abstract ")){
      cachedClasses.add(stream.readAbstractClass(cachedAnnotations));
      return true;
    }

    if(line.startsWith("class ")){
      cachedClasses.add(stream.readClass(cachedAnnotations));
      return true;
    }
    return false;
  }


}


class DocumentParser extends Context{
  final String path;
  DocumentParser(this.path);

  Document parse(LineStream stream){

    while(stream.hasNextString()){
      String line = stream.peekString();

      if(parseLine(stream,line)){
        continue;
      }
      //skip other
      stream.skipLine();
    }


    return new Document(
      path:path,
      methods: cachedMethod,
      fields: cachedField,
      classes: cachedClasses
    );


  }

}

class FastParser {

  /// parse a single dart file
  static Document parse( String path ){
    File file = new File(path);
    if(!file.existsSync()){
      throw new Exception("File $path not found");
    }
    return parseFile(file);
  }


  static Document parseFile( File path ){
    List<String> lines=  path.readAsLinesSync();
    /// we just parse the document line by line
    LineStream stream = new LineStream(lines);
    return new DocumentParser(path.path).parse(stream);
  }

}


//this.xxx constructor
//a
//int a
//void func()
//{}

RegExp classAnnotation = new RegExp(r"@([a-zA-Z$_]+)\(([^\)]*)\)");
RegExp constAnnotation = new RegExp(r"@([a-zA-Z$_]+)");
// const Type a =
RegExp variableExp = new RegExp(r"([[a-zA-Z0-9$_<>]+[\s]+]*)([a-zA-Z0-9$_]+)[\s]*[=|;]");

RegExp methodExp = new RegExp(r"([a-zA-Z0-9$_<>]*)[\s]+([a-zA-Z0-9$_]+)[\s]*\(");
RegExp classRegExp = new RegExp(r"class[\s]+([A-Za-z0-9_$]+)[\s]*\{");

RegExp namedCall = new RegExp(r"([a-zA-Z0-9$_]+)[\s]*:");

RegExp intReg = new RegExp("[0-9]+");
RegExp doubleReg = new RegExp("[0-9]+.[0-9]+");

