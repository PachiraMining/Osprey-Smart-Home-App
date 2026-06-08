import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/pairing/data/datasources/osprey_adv_parser.dart';

void main() {
  group('OspreyAdvParser', () {
    // Ví dụ hex từ spec §3.4: curtain ở pairing mode
    // frameCtrl=0x00, productType=0x0001 (BE), hash=A0CE10
    test('parse adv curtain pairing mode (spec §3.4)', () {
      final data = OspreyAdvParser.parse([0x00, 0x00, 0x01, 0xA0, 0xCE, 0x10]);
      expect(data, isNotNull);
      expect(data!.isPaired, false);
      expect(data.isEncrypted, false);
      expect(data.protocolVersion, 0);
      expect(data.productType, 1);
      expect(data.productIdHashHex, 'a0ce10');
    });

    test('paired flag (bit 0) = 1 → isPaired', () {
      final data = OspreyAdvParser.parse([0x01, 0x00, 0x01, 0xA0, 0xCE, 0x10]);
      expect(data!.isPaired, true);
    });

    test('encrypted flag (bit 1) = 1 → isEncrypted', () {
      final data = OspreyAdvParser.parse([0x02, 0x00, 0x01, 0xA0, 0xCE, 0x10]);
      expect(data!.isEncrypted, true);
      expect(data.isPaired, false);
    });

    test('protocol version từ bit 2-7', () {
      // frameCtrl = 0b000001_00 = version 1
      final data = OspreyAdvParser.parse([0x04, 0x00, 0x01, 0xA0, 0xCE, 0x10]);
      expect(data!.protocolVersion, 1);
    });

    test('productType big-endian (high byte trước)', () {
      final data = OspreyAdvParser.parse([0x00, 0x01, 0x02, 0xA0, 0xCE, 0x10]);
      expect(data!.productType, 0x0102);
    });

    test('payload quá ngắn → null', () {
      expect(OspreyAdvParser.parse([0x00, 0x00, 0x01]), isNull);
      expect(OspreyAdvParser.parse([]), isNull);
    });

    test('payload dài hơn 6 bytes vẫn parse được 6 bytes đầu', () {
      final data = OspreyAdvParser.parse(
          [0x00, 0x00, 0x01, 0xA0, 0xCE, 0x10, 0xDE, 0xAD]);
      expect(data!.productIdHashHex, 'a0ce10');
    });
  });
}
