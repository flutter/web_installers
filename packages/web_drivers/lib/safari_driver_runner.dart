// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

/// Running Safari Driver which comes installed in every macOS operation system.
///
/// The version of driver is the same as the version of the Safari installed
/// in the system.
class SafariDriverRunner {
  /// Start Safari Driver installed in the macOS operating system.
  ///
  /// If a specific version is requested, it will check the existing system
  /// version and throw and exception the versions do not match.
  ///
  /// If the operating system is not macOS, the method will throw an exception.
  Future<void> start({String version = 'system'}) async {
    if (!io.Platform.isMacOS) {
      throw AssertionError('The operating system must be MacOS: '
          '${io.Platform.operatingSystem}');
    }
    final io.Process process = await runDriver(version: version);
    final int exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception('Driver failed with exitcode: $exitCode');
    }
  }

  /// Safari Driver needs to be enabled before it is used.
  ///
  /// The driver will need to get re-enabled after the machine is restarted.
  ///
  /// The enabling waits for user input for authentication.
  void _enableDriver() {
    io.Process.runSync('/usr/bin/safaridriver', ['--enable']);
  }

  /// Compare the version of the installed driver to the requested version.
  ///
  /// Throw an exception if they don't match.
  Future<void> _compareDriverVersion(String version) async {
    io.Process.run('/usr/bin/safaridriver', ['--version']);

    final io.ProcessResult versionResult =
        await io.Process.run('/usr/bin/safaridriver', ['--version']);

    if (versionResult.exitCode != 0) {
      throw Exception('Failed to get the safari driver version.');
    }
    // The output generally looks like: Included with Safari 13.0.5 (14608.5.12)
    final String output = versionResult.stdout as String;
    final String rest =
        output.substring(output.indexOf('Safari'));

    print('INFO: driver version in the system: $rest');

    // Version number such as 13.0.5.
    final String versionAsString = rest.trim().split(' ')[1];

    if (versionAsString != version) {
      throw Exception('System version $versionAsString did not match requested '
          'version $version');
    }
  }

  /// Run Safari Driver installed in the macOS operating system and return
  /// the driver Process.
  ///
  /// Returns a `Future<Process>` that completes with a
  /// Process instance when the process has been successfully
  /// started. That [Process] object can be used to interact with the
  /// process. If the process cannot be started the returned [Future]
  /// completes with an exception.
  ///
  /// If a specific version is requested, it will check the existing system
  /// version and throw and exception the versions do not match.
  Future<io.Process> runDriver({String version = 'system'}) async {
    _enableDriver();
    if (version != 'system') {
      await _compareDriverVersion(version);
      print('INFO: Safari Driver will start with version $version on port '
          '4444');
    } else {
      // Driver does not have any output.
      // Printing this one as a info message.
      print('INFO: Safari Driver will start on port 4444.');
    }

    return io.Process.start('/usr/bin/safaridriver', ['--port=4444']);
  }
}
