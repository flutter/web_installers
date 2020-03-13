// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:test/test.dart';
import 'package:web_driver_installer/chrome_driver_installer.dart';

void main() async {
  void deleteInstallationIfExists() {
    final io.Directory driverInstallationDir = io.Directory('chromedriver');

    if (driverInstallationDir.existsSync()) {
      driverInstallationDir.deleteSync(recursive: true);
    }
  }

  setUpAll(() {
    deleteInstallationIfExists();
  });

  tearDown(() {
    deleteInstallationIfExists();
  });

  test('installs chrome driver', () async {
    ChromeDriverInstaller command = ChromeDriverInstaller();
    expect(command.isInstalled, isFalse);
    await command.install();

    expectLater(command.isInstalled, isTrue);
  });

  test('get chrome version on MacOS', () async {
    String executable =
        await ChromeDriverInstaller().findChromeExecutableOnMac();
    final io.ProcessResult processResult =
        await io.Process.run(executable, <String>['--version']);

    expect(processResult.exitCode, 0);
    expect(processResult.stdout.toString().startsWith('Google Chrome'), isTrue);
  }, skip: !io.Platform.isMacOS);
}
