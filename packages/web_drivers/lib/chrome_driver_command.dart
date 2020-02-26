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

  ChromeDriverCommand() {
    argParser
      ..addFlag(
        'install-only',
        defaultsTo: false,
        help: 'Only installs the driver. Does not start it. Default is false',
      );
  }

  final ChromeDriverInstaller chromeDriverInstaller = ChromeDriverInstaller();

  @override
  Future<bool> run() async {
    final bool installOnly = argResults['install-only'];

    if (installOnly) {
      return await chromeDriverInstaller.install();
    } else {
      try {
        await chromeDriverInstaller.start();
      } catch (e) {
        print('Exception during install $e');
        return false;
      }
      return true;
    }
  }
}
