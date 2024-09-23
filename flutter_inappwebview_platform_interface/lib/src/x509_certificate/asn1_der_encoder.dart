import 'dart:typed_data';
import 'asn1_identifier.dart';

class ASN1DEREncoder {
  static Uint8List encodeSequence({required Uint8List content}) {
    var encoded = Uint8List.fromList([]);
    encoded.add(ASN1Identifier.constructedTag |
        ASN1IdentifierTagNumber.SEQUENCE.toValue());
    encoded.addAll(contentLength(size: content.length));
    encoded.addAll(content);
    return Uint8List.fromList(encoded);
  }

  static Uint8List contentLength({required int size}) {
    if (size >= 128) {
      var lenBytes = Uint8List(size);
      while (lenBytes.first == 0) {
        lenBytes.removeAt(0);
      }
      int len = 0x80 | lenBytes.length;
      return Uint8List(len)..addAll(lenBytes);
    } else {
      return Uint8List(size);
    }
  }
}
