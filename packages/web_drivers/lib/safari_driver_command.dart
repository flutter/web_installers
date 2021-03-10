// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:web_driver_installer/safari_driver_runner.dart';

/// Wrapper class on top of [SafariDriverRunner] to use it as a command.
class SafariDriverCommand extends Command<bool> {
  @override
  String get description => 'Safari Driver runner.';

  @override
  String get name => 'safaridriver';

  /// If the version is provided as an argument, it is checked against the
  /// system version and an exception is thrown if they do not match.
  final String defaultDriverVersion = 'system';

  SafariDriverCommand() {
    argParser
      ..addOption('driver-version',
          defaultsTo: defaultDriverVersion,
          help: 'Run the given version of the driver. If the given version '
              'does not exists throw an error.');
  }

  final SafariDriverRunner safariDriverRunner = SafariDriverRunner();

  @override
  Future<bool> run() async {
    final String driverVersion = argResults!['driver-version'];
    try {
      await safariDriverRunner.start(version: driverVersion);
      return true;
    } catch (e) {
      print('Exception during running the safari driver: $e');
      return false;
    }
  }
}
