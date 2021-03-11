// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:web_driver_installer/chrome_driver_installer.dart';

/// Wrapper class on top of [ChromeDriverInstaller] to use it as a command.
class ChromeDriverCommand extends Command<bool> {
  @override
  String get description => 'Chrome Driver installer.';

  @override
  String get name => 'chromedriver';

  static const String defaultDriverVersion = 'fromlockfile';

  ChromeDriverCommand() {
    argParser
      ..addFlag('always-install',
          defaultsTo: false,
          help: 'Overwrites an existing driver installation, if any. There '
              'might be an already installed version of the driver. This '
              'flag will delete it before installing a new one.')
      ..addFlag('install-only',
          defaultsTo: false,
          help: 'Only installs the driver. Does not start it. Default is false')
      ..addOption('driver-version',
          defaultsTo: defaultDriverVersion,
          help: 'Install the given version of the driver. If driver version is '
              'not provided use version from the driver_version.yaml.');
  }

  /// If the version is provided as an argument, initialize using the version
  /// otherwise use the `driver_version.yaml` file.
  ///
  /// See [_initializeChromeDriverInstaller].
  late ChromeDriverInstaller chromeDriverInstaller;

  @override
  Future<bool> run() async {
    final bool installOnly = argResults!['install-only'];
    final bool alwaysInstall = argResults!['always-install'];

    _initializeChromeDriverInstaller();

    try {
      if (installOnly) {
        await chromeDriverInstaller.install(alwaysInstall: alwaysInstall);
      } else {
        await chromeDriverInstaller.start(alwaysInstall: alwaysInstall);
      }
      return true;
    } catch (e) {
      print('Exception during install $e');
      return false;
    }
  }

  void _initializeChromeDriverInstaller() {
    final String driverVersion = argResults!['driver-version'];
    if (driverVersion == defaultDriverVersion) {
      chromeDriverInstaller = ChromeDriverInstaller();
    } else {
      chromeDriverInstaller = ChromeDriverInstaller.withVersion(driverVersion);
    }
  }
}
