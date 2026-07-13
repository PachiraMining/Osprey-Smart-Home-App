// Quick-and-dirty: in golden vectors cho firmware team cross-verify.
// Chạy: fvm flutter test test/features/control/golden_vector_print.dart
// Không phải test thực sự — dùng `print` cố ý để output hex.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/control/data/crypto/ble_control_crypto.dart';
import 'package:smart_curtain_app/features/pairing/data/crypto/hex_utils.dart';

void main() {
  test('print golden vectors for firmware verification (spec v2 §5.2)', () {
    final crypto = BleControlCrypto();
    // Reference session_key = HKDF(PSK=0xAA×32, nonce=0×16) — handoff §3.
    final sessionKey = Uint8List.fromList(HexUtils.decode(
        '08df2a1f3972b6157fbbc66434f520d5ba24d64657fe66d0fc2f784d097a9bfa'));

    print('');
    print('=== Golden vectors for BLE_CONTROL_CMD wire format v2 ===');
    print('session_key = 08df2a1f3972b6157fbbc66434f520d5'
        'ba24d64657fe66d0fc2f784d097a9bfa');
    print('             (= HKDF(PSK=0xAA×32, nonce=0×16) — pairing ref §3)');
    print('key[0..16]  = ${HexUtils.encode(sessionKey.sublist(0, 16))}');
    print('');

    for (final cmd in ['{"cmd":"open"}', '{"cmd":"close"}', '{"cmd":"stop"}']) {
      for (final counter in [1, 2, 0xFFFFFFFF]) {
        final plain = utf8.encode(cmd);
        final wire = crypto.encryptCommand(
          sessionKey: sessionKey,
          counter: counter,
          plaintext: plain,
        );
        final counterHex = HexUtils.encode(wire.sublist(0, 8));
        final ctTag = HexUtils.encode(wire.sublist(8));
        print('cmd=$cmd, counter=0x${counter.toRadixString(16).padLeft(16, '0')}');
        print('  IV (derived) = $counterHex 00000000');
        print('  wire (${wire.length}B) = $counterHex | $ctTag');
        print('');
      }
    }
  });
}
