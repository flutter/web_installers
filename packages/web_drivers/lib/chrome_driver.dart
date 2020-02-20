// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'common.dart';

class ChromeDriverCommand extends Command<bool> {
  /// HTTP client used to download Chrome Driver.
  final Client client = Client();

  /// Installation directory for Chrome Driver.
  final io.Directory driverDir = io.Directory('chromedriver');

  /// File that should contain Chrome Driver.
  io.File exitingFile;

  static const String chromerDriversUrl =
      'https://chromedriver.storage.googleapis.com/';

  String chromeDriverVersion;

  io.File driverDownload;

  String get downloadUrl =>
      '$chromerDriversUrl$chromeDriverVersion/chromedriver_linux64.zip';

  @override
  String get description => 'Chrome Driver installer.';

  @override
  String get name => 'chromedriver';

  bool get isInstalled =>
      io.File(path.join(driverDir.path, 'chromedriver')).existsSync();

  Future<void> start() async {
    // Install Chrome Driver.
    try {
      final bool isSuccessfullyInstalled = await install();
      if (isSuccessfullyInstalled) {
        // Start using chromedriver --port=4444
        print('starting Chrome Driver on port 4444');
        await runDriver();
      }
    } finally {
      driverDownload?.deleteSync();
    }
  }

  Future<bool> install() async {
    if (!isInstalled) {
      return await _installDriver();
    } else {
      return true;
    }
  }

  Future<bool> _installDriver() async {
    // Check chrome version.
    bool successfulInstall = false;
    final int chromeVersion = await _querySystemChromeVersion();

    if (chromeVersion == null || chromeVersion < 79) {
      throw Exception('Unsupported Chrome version: $chromeVersion');
    }

    final YamlMap browserLock = DriverLock.instance.configuration;
    chromeDriverVersion = browserLock['chrome'][chromeVersion] as String;

    try {
      driverDownload = await _downloadDriver();
    } catch (e) {
      throw Exception(
          'Failed to download chrome driver $chromeDriverVersion. $e');
    } finally {
      client.close();
    }

    await _uncompress();
    successfulInstall = true;

    return successfulInstall;
  }

  Future<int> _querySystemChromeVersion() async {
    final io.ProcessResult versionResult =
        await io.Process.run('google-chrome', <String>['--version']);

    if (versionResult.exitCode != 0) {
      throw Exception('Failed to locate system Chrome.');
    }
    // The output looks like: Google Chrome 79.0.3945.36.
    final String output = versionResult.stdout as String;

    // Version number such as 79.0.3945.36.
    final String versionAsString = output.split(' ')[2];

    final String versionNo = versionAsString.split('.')[0];

    return int.parse(versionNo);
  }

  Future<io.File> _downloadDriver() async {
    if (driverDir.existsSync()) {
      driverDir.deleteSync(recursive: true);
    }

    driverDir.createSync(recursive: true);

    print('downloading file from $downloadUrl');

    final StreamedResponse download = await client.send(Request(
      'GET',
      Uri.parse(downloadUrl),
    ));

    final io.File downloadedFile =
        io.File(path.join(driverDir.path, 'chromedriver_linux64.zip'));
    await download.stream.pipe(downloadedFile.openWrite());

    return downloadedFile;
  }

  /// Uncompress the downloaded driver file.
  Future<void> _uncompress() async {
    final io.ProcessResult unzipResult = await io.Process.run('unzip', <String>[
      driverDownload.path,
      '-d',
      driverDir.path,
    ]);

    if (unzipResult.exitCode != 0) {
      throw Exception(
          'Failed to unzip the downloaded Chrome driver ${driverDownload.path}.\n'
          'With the driver path ${driverDir.path}\n'
          'The unzip process exited with code ${unzipResult.exitCode}.');
    }
  }

  Future<void> runDriver() async {
    await io.Process.run('chromedriver', <String>['--port=4444']);
  }
}
