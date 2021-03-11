// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'src/common.dart';

class FirefoxDriverInstaller {
  /// HTTP client used to download Firefox Driver.
  final Client client = Client();

  /// Installation directory for Firefox Driver.
  final io.Directory driverDir = io.Directory('firefoxdriver');

  static const String geckoDriverReleasesUrl =
      'https://github.com/mozilla/geckodriver/releases/download';

  /// Version of geckodriver release at github.com/mozilla/geckodriver project.
  ///
  /// This is not the version of Firefox Browser.
  ///
  /// Geckodriver works for multiple versions of Firefox Browser.
  late String geckoDriverVersion;

  FirefoxDriverInstaller({String geckoDriverVersion = ''}) {
    if (geckoDriverVersion.isEmpty) {
      print('INFO: No geckoDriverVersion is given. Using geckodriver from '
          'driver_version.yaml file.');
      final YamlMap driverLock = DriverLock.instance.configuration;
      this.geckoDriverVersion = driverLock['gecko'] as String;
    }
    this.geckoDriverVersion = geckoDriverVersion;
  }

  io.File? driverDownload;

  String get downloadUrl => '$geckoDriverReleasesUrl/${driverUrlPath()}';

  bool get isInstalled => driverDir.existsSync();

  Future<void> start({bool alwaysInstall = false}) async {
    // Install Driver.
    try {
      await install(alwaysInstall: alwaysInstall);
      await runDriver();
    } finally {
      // Only delete if the user is planning to override the installs.
      // Keeping the existing version might make local development easier.
      // Also if a CI build runs multiple felt commands using an existing
      // version speeds up the build.
      if (!alwaysInstall) {
        driverDownload?.deleteSync();
      }
    }
  }

  Future<void> install({bool alwaysInstall = false}) async {
    if (!isInstalled || alwaysInstall) {
      await _installDriver();
    } else {
      print('INFO: Installation skipped. The driver is installed: '
          '$isInstalled. User requested force install: $alwaysInstall');
    }
  }

  Future<void> _installDriver() async {
    // If this method is called, clean the previous installations.
    try {
      driverDownload = await _downloadDriver();
    } catch (e) {
      throw Exception(
          'Failed to download driver Firefox from link $downloadUrl. $e');
    } finally {
      client.close();
    }

    if (io.Platform.isWindows) {
      await _uncompressWithZip(driverDownload!);
    } else {
      await _uncompressWithTar(driverDownload!);
    }
  }

  Future<io.File> _downloadDriver() async {
    if (driverDir.existsSync()) {
      driverDir.deleteSync(recursive: true);
    }

    driverDir.createSync(recursive: true);

    final StreamedResponse download = await client.send(Request(
      'GET',
      Uri.parse(downloadUrl),
    ));

    final io.File downloadedFile =
        io.File(path.join(driverDir.path, geckoDriverVersion));

    final io.IOSink sink = downloadedFile.openWrite();
    await download.stream.pipe(sink);
    await sink.flush();
    await sink.close();

    return downloadedFile;
  }

  /// Uncompress the downloaded driver file.
  Future<void> _uncompressWithZip(io.File downloadedFile) async {
    final io.ProcessResult unzipResult = await io.Process.run('unzip', <String>[
      driverDownload!.path,
      '-d',
      driverDir.path,
    ]);

    if (unzipResult.exitCode != 0) {
      throw Exception(
          'Failed to unzip the downloaded gecko driver ${driverDownload!.path}.\n'
          'With the driver path ${driverDir.path}\n'
          'The unzip process exited with code ${unzipResult.exitCode}.');
    }
  }

  /// Start using firefoxdriver --port=4444
  Future<io.ProcessResult> runDriver() async {
    print('INFO: Starting Firefox Driver on port 4444');
    return await io.Process.run(
        'firefoxdriver/geckodriver', <String>['--port=4444']);
  }

  /// Uncompress the downloaded browser files for operating systems that
  /// use a zip archive.
  /// See [version].
  Future<void> _uncompressWithTar(io.File downloadedFile) async {
    final io.ProcessResult unzipResult = await io.Process.run('tar', <String>[
      '-x',
      '-f',
      downloadedFile.path,
      '-C',
      driverDir.path,
    ]);

    if (unzipResult.exitCode != 0) {
      throw Exception(
          'Failed to unzip the downloaded Firefox archive ${downloadedFile.path}.\n'
          'The unzip process exited with code ${unzipResult.exitCode}.');
    }
  }

  /// Driver name for operating system.
  ///
  /// Drivers can be found at:
  /// https://github.com/mozilla/geckodriver/releases/
  String driverUrlPath() {
    if (io.Platform.isMacOS) {
      return '${geckoDriverVersion}/geckodriver-${geckoDriverVersion}-'
          'macos.tar.gz';
    } else if (io.Platform.isLinux) {
      return '${geckoDriverVersion}/geckodriver-${geckoDriverVersion}-'
          'linux64.tar.gz';
    } else if (io.Platform.isWindows) {
      return '${geckoDriverVersion}/geckodriver-${geckoDriverVersion}-'
          'win64.zip';
    } else {
      throw UnimplementedError('Automated testing not supported on this OS.'
          'Platform name: ${io.Platform.operatingSystem}');
    }
  }
}
