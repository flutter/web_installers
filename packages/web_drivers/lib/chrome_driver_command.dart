// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:web_driver_installer/chrome_driver_installer.dart';

// Wrapper class on top of ChromeDriverInstaller to use it as a command.
class ChromeDriverCommand extends Command<bool> {
  @override
  String get description => 'Chrome Driver installer.';

  @override
  String get name => 'chromedriver';

  final ChromeDriverInstaller chromeDriverInstaller = ChromeDriverInstaller();

  // Trigger Chrome Driver start.
  Future<void> start() async {
    await chromeDriverInstaller.start();
  }

  // Trigger Chrome Driver install.
  Future<bool> install() async {
    return await chromeDriverInstaller.install();
  }
}
