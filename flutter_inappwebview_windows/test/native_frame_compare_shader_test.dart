import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  test('the frame comparer uses precompiled shader bytecode', () {
    final bridge = _readNativeSource(
      'windows/custom_platform_view/texture_bridge_gpu.cc',
    );
    final header = _readNativeSource(
      'windows/custom_platform_view/frame_compare_cs.h',
    );

    // Loading and running d3dcompiler_47.dll on the platform thread took
    // seconds on slow disks (Otzaria/otzaria#3536).
    expect(bridge.toLowerCase(), isNot(contains('d3dcompiler')));
    expect(bridge, isNot(contains('D3DCompile')));
    expect(bridge, contains('#include "frame_compare_cs.h"'));
    expect(bridge, contains('CreateComputeShader(kFrameCompareCs,'));
    expect(header, contains('const BYTE kFrameCompareCs[] ='));
    expect(header, contains('cs_5_0'));
  });
}
