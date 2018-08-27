import 'package:fast_parser/fast_parser.dart';

fun() {}

void main() {
  Document document = FastParser
      .parse("/Users/jzoom/working/fast_parser/example/lib/TestService.dart");
  print(document);
}
