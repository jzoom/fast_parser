
class Util{

  static Iterable<String> indent(String str) sync*{
    List<String> lines = str.split("\n");

    for(String l in lines){
      yield "  $l";
    }
  }
}