// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import '../lib/simulator_manager.dart';

void main() async {
  test('boot simulator', () async {
    IosSimulatorManager simulatorManager = IosSimulatorManager();
    IosSimulator simulator =
        await simulatorManager.getSimulator(13, 0, 'iPhone 11');
    await simulator.boot();
  });

  test('shutdown simulator', () async {
    IosSimulatorManager simulatorManager = IosSimulatorManager();
    IosSimulator simulator =
        await simulatorManager.getSimulator(13, 0, 'iPhone 11');
    await simulator.shutdown();
  });
}
