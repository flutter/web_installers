// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:web_driver_installer/firefox_driver_installer.dart';

/// Wrapper class on top of [FirefoxDriverInstaller] to use it as a command.
class FirefoxDriverCommand extends Command<bool> {
  @override
  String get description => 'Firefox Driver installer.';

  @override
  String get name => 'firefoxdriver';

  static const String defaultDriverVersion = 'fromlockfile';

  FirefoxDriverCommand() {
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
          help: 'Install the given release from the geckodriver releases. If '
              'release version is not provided use version from the '
              'driver_version.yaml. For releases see: '
              'https://github.com/mozilla/geckodriver/releases');
  }

  /// If the gecko driver release version is provided as an argument,
  /// initialize using it otherwise use the one from  `driver_version.yaml`
  /// file.
  ///
  /// See [_initializeFirefoxDriverInstaller].
  late FirefoxDriverInstaller firefoxDriverInstaller;

  @override
  Future<bool> run() async {
    final bool installOnly = argResults!['install-only'];
    final bool alwaysInstall = argResults!['always-install'];

    _initializeFirefoxDriverInstaller();

    try {
      if (installOnly) {
        await firefoxDriverInstaller.install(alwaysInstall: alwaysInstall);
      } else {
        await firefoxDriverInstaller.start(alwaysInstall: alwaysInstall);
      }
      return true;
    } catch (e) {
      throw Exception('Exception during Firefox command: $e');
    }
  }

  void _initializeFirefoxDriverInstaller() {
    final String driverVersion = argResults!['driver-version'];
    if (driverVersion == defaultDriverVersion) {
      firefoxDriverInstaller = FirefoxDriverInstaller();
    } else {
      firefoxDriverInstaller =
          FirefoxDriverInstaller(geckoDriverVersion: driverVersion);
    }
  }
}
