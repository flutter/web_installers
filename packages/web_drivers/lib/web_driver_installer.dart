// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';

import 'chrome_driver.dart';

CommandRunner runner = CommandRunner<bool>(
  'webdriver-install',
  'Command-line utility for installing web drivers for web integration tests '
      'with flutter driver.',
)..addCommand(ChromeDriverCommand());

void main(List<String> args) async {
  // TODO(nurhan): Start/only install driver depending on arg.
  // TODO(nurhan): Add more browsers' drivers. Control with command line args.
  try {
    await ChromeDriverCommand().start();
  } on UsageException catch (e) {
    print(e);
    io.exit(64); // Exit code 64 indicates a usage error.
  } catch (e) {
    rethrow;
  }

  // Sometimes the Dart VM refuses to quit.
  io.exit(io.exitCode);
}
