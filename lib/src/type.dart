

class ParsedType{
  final String type;

  ParsedType({
    this.type
});

  factory ParsedType.parse(String type) {
    return new ParsedType(type: type);
  }

  @override
  String toString() {
    return type;
  }

}