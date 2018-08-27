
class Annotation{

  final String name;

  Annotation({
    this.name
});


  @override
  String toString() {
    return "@$name";
  }

}


class ClassAnnotation extends Annotation{

  final List ordered;
  final Map<String,dynamic> named;

  ClassAnnotation({
    String name,
    this.ordered,
    this.named
}) : super(name : name);

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();

    sb.write("@");
    sb.write(name);

    sb.write("(");
    bool first = true;

    ordered.forEach((d){
      if(first ){
        first = false;
      }else{
        sb.write(",");
      }
      sb.write(d);
    });

    first = true;

    if( ordered.length > 0 ){
      sb.write(",");
    }

    named.forEach( (k,d){
      sb.write(k);
      sb.write(":");
      if(d is String){
        sb.write('"');
        sb.write(d);
        sb.write('"');
      }else
        sb.write(d);
    });

    sb.write(")");

    return sb.toString();
  }

}