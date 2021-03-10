// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:web_driver_installer/firefox_driver_command.dart';

import 'chrome_driver_command.dart';
import 'safari_driver_command.dart';

CommandRunner runner = CommandRunner<bool>(
  'webdriver-install',
  'Command-line utility for installing web drivers for web integration tests '
      'with flutter driver.',
)
  ..addCommand(ChromeDriverCommand())
  ..addCommand(FirefoxDriverCommand())
  ..addCommand(SafariDriverCommand());

void main(List<String> args) async {
  // TODO(nurhan): Add more browsers' drivers. Control with command line args.
  try {
    // For now add chromedriver if no argument exists. This is not to break
    // exisiting tests.
    // TODO(nurhan): Fix smoke test in flutter to pass chromedriver as an arg.
    if (args.isEmpty) {
      await runner.run(<String>['chromedriver']);
    } else {
      await runner.run(args);
    }
  } on UsageException catch (e) {
    print(e);
    io.exit(64); // Exit code 64 indicates a usage error.
  } catch (e) {
    rethrow;
  }

  // Sometimes the Dart VM refuses to quit.
  io.exit(io.exitCode);
}
