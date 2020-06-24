// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

/// Manages iOS Simulators.
///
/// Creates a simulator or provides access to an existing simulator by
/// returning [IOSSimulator] instances.
///
/// Uses `xcrun simctl` command to manage the simulators.
///
/// Run `xcrun simctl --help` to learn more on the details of this tool.
class IosSimulatorManager {
  IosSimulatorManager() {
    if (!io.Platform.isMacOS) {
      throw Exception('Platform ${io.Platform.operatingSystem} is not supported'
          '. This class should only be used on macOS. It uses xcrun '
          'simctl command line tool to manage the iOS simulators');
    }
  }

  /// Uses `xcrun simctl create` command to create an iOS Simulator.
  ///
  /// Runs `xcrun simctl list runtimes` to list the runtimes existing on your
  /// macOS. If runtime derived from [majorVersion] and [minorVersion] is not
  /// available an exception will be thrown. Use Xcode to install more versions.
  ///
  /// [device] example iPhone 11 Pro. Run `xcrun simctl list devicetypes` to
  /// list the device types available. If [device] is not available, an
  /// exception will be thrown. Use Xcode to install more versions.
  ///
  /// Use `xcrun simctl create --help` for more details.
  Future<IosSimulator> createSimulator(
      int majorVersion, int minorVersion, String device) async {
    final String runtime = 'iOS ${majorVersion}.${minorVersion}';

    // Check if the runtime is available.
    final io.ProcessResult runtimeListResult =
        await io.Process.run('xcrun', ['simctl', 'list', 'runtimes']);

    if (runtimeListResult.exitCode != 0) {
      throw Exception('Failed to boot list runtimes(versions). Command used: '
          'xcrun simctl list runtimes');
    }

    final String output = runtimeListResult.stdout as String;
    if (!output.contains(runtime)) {
      throw Exception('Mac does not have the requested $runtime '
          'available for simulators. Please use XCode to install.');
    }

    // Check if the device is available.
    final io.ProcessResult deviceListResult =
        await io.Process.run('xcrun', ['simctl', 'list', 'devicetypes']);

    if (deviceListResult.exitCode != 0) {
      throw Exception('Failed to boot list available simulator device types.'
          'Command used: xcrun simctl list devicetypes');
    }

    final String deviceListOutput = deviceListResult.stdout as String;
    if (!deviceListOutput.contains(device)) {
      throw Exception('Mac does not have the requested device type $device '
          'available for simulators. Please use XCode to install.');
    }

    // Prepate device type argument. It should look like:
    // com.apple.CoreSimulator.SimDeviceType.iPhone-11-Pro
    final String deviceTypeAsArg =
        'com.apple.CoreSimulator.SimDeviceType.${device.replaceAll(' ', '-')}';

    // Prepare runtime as argument using the versions. It should look like:
    // com.apple.CoreSimulator.SimRuntime.iOS-13-1.
    final String runtimeTypeAsArg =
        'com.apple.CoreSimulator.SimRuntime.iOS-${majorVersion}-${minorVersion}';

    final io.ProcessResult createResult = await io.Process.run('xcrun',
        ['simctl', 'create', device, deviceTypeAsArg, runtimeTypeAsArg]);

    if (createResult.exitCode != 0) {
      throw Exception('Failed to create requested simulator using $device '
          '$deviceTypeAsArg $runtimeTypeAsArg arguments.');
    }

    // Output will have the simulator id.
    final String simulatorId = createResult.stdout as String;
    return IosSimulator._(false, simulatorId.trim());
  }

  /// Returns an [IosSimulator] instance to control the simulator,
  /// if a simulator corresponding to given [osVersion] and [phone] information
  /// exits.
  ///
  /// Throws if such a simulator is not available.
  Future<IosSimulator> getSimulator(
      int osMajorVersion, int osMinorVersion, String phone) async {
    final String simulatorVersion =
        '-- iOS ${osMajorVersion}.${osMinorVersion} --';
    final String simulatorsList =
        await _listExistingSimulators(osMajorVersion, osMinorVersion);

    // The simulator list, have the version string followed by a list of phone
    // names along with their ids and their statuses. Example output 1:
    // -- iOS 13.5 --
    //   iPhone 8 (2A437C91-3B85-4D7B-BB91-32561DA07B85) (Shutdown)
    //   iPhone 8 Plus (170207A8-7631-4CBE-940E-86A7815AEB2B) (Shutdown)
    //   iPhone 11 (7AEC5FB9-E08A-4F7F-8CA2-1518CE3A3E0D) (Booted)
    //   iPhone 11 Pro (D8074C8B-35A5-4DA5-9AB2-4CE738A5E5FC) (Shutdown)
    //   iPhone 11 Pro Max (3F33AD9A-805E-43E0-A86C-8FC70464A390) (Shutdown)
    // -- iOS 13.6 --
    //   iPhone 8 (2A437C91-3B85-4D7B-BB91-32561DA07B85) (Shutdown)
    //   iPhone 8 Plus (170207A8-7631-4CBE-940E-86A7815AEB2B) (Shutdown)
    //   iPhone 11 (7AEC5FB9-E08A-4F7F-8CA2-1518CE3A3E0D) (Booted)
    //   iPhone 11 Pro (D8074C8B-35A5-4DA5-9AB2-4CE738A5E5FC) (Shutdown)
    // -- Device Pairs --
    // Example output 2 (from Mac Web Engine try bots):
    // == Devices ==
    // -- iOS 13.0 --
    //     iPhone 8 (C142C9F5-C26E-4EB5-A2B8-915D5BD62FA5) (Shutdown)
    //     iPhone 8 Plus (C1FE8FAA-5797-478E-8BEE-D7AD4811F08C) (Shutdown)
    //     iPhone 11 (28A3E6C0-76E7-4EE3-9B34-B059C4BBE5CA) (Shutdown)
    //     iPhone 11 Pro (0AD4BBA5-7BE7-415D-B9FD-D962FA8E1782) (Shutdown)
    //     iPhone 11 Pro Max (1280DE05-B334-4E60-956F-4A62220DEFA3) (Shutdown)
    //     iPad Pro (9.7-inch) (EDE46501-CB2B-4EA4-8B5C-13FAC6F2EC91) (Shutdown)
    //     iPad Pro (11-inch) (E0B89C9C-6200-495C-B18B-0078CCAAC688) (Shutdown)
    //     iPad Pro (12.9-inch) (3rd generation) (DB3EB7A8-C4D2-4F86-AFC1-D652FB0579E8) (Shutdown)
    //     iPad Air (3rd generation) (9237DCD8-8F0E-40A6-96DF-B33C915AFE1B) (Shutdown)
    // == Device Pairs ==
    final int indexOfVersionListStart =
        simulatorsList.indexOf(simulatorVersion);
    final String restOfTheOutput = simulatorsList
        .substring(indexOfVersionListStart + simulatorVersion.length);
    int indexOfNextVersion = restOfTheOutput.indexOf('--');
    if (indexOfNextVersion == -1) {
      // Search for `== Device Pairs ==`.
      indexOfNextVersion = restOfTheOutput.indexOf('==');
    }
    if (indexOfNextVersion == -1) {
      // Set to end of file.
      indexOfNextVersion = restOfTheOutput.length;
    }

    final String listOfPhones =
        restOfTheOutput.substring(0, indexOfNextVersion);

    final int indexOfPhone = listOfPhones.indexOf(phone);
    if (indexOfPhone == -1) {
      throw Exception('Simulator of $phone is not available for iOS version '
          '${osMajorVersion}.${osMinorVersion}');
    }

    final String phoneInfo = listOfPhones.substring(indexOfPhone);
    final int endIndexOfPhoneId = phoneInfo.indexOf(')');
    final String simulatorId =
        phoneInfo.substring(phoneInfo.indexOf('(') + 1, endIndexOfPhoneId);

    final String phoneInfoAfterId = phoneInfo.substring(endIndexOfPhoneId + 1);
    final String simulatorStatus = phoneInfoAfterId.substring(
        phoneInfoAfterId.indexOf('(') + 1, phoneInfoAfterId.indexOf(')'));
    return IosSimulator._(simulatorStatus == 'Booted', simulatorId);
  }

  Future<String> _listExistingSimulators(
      int osMajorVersion, int osMinorVersion) async {
    final io.ProcessResult versionResult =
        await io.Process.run('xcrun', ['simctl', 'list']);

    if (versionResult.exitCode != 0) {
      throw Exception('Failed to list iOS simulators.');
    }
    final String output = versionResult.stdout as String;
    // If the requested iOS version simulators exists, there should be a block
    // starting with: `-- iOS osMajorVersion.osMinorVersion --`
    final bool versionCheck =
        output.contains('-- iOS ${osMajorVersion}.${osMinorVersion} --');

    if (!versionCheck) {
      throw Exception(
          'Requested simulator version iOS ${osMajorVersion}.${osMinorVersion} '
          'is not available.');
    }

    return output;
  }
}

/// A class that can be used to boot/shutdown an iOS Simulator.
class IosSimulator {
  final String id;

  bool _booted;
  bool get booted => _booted;

  IosSimulator._(this._booted, this.id);

  /// Boots the iOS Simulator using the simulator [id].
  ///
  /// Uses `xcrun simctl boot` command to boot an iOS Simulator.
  ///
  /// If it is already booted the command will fail.
  Future<void> boot() async {
    final io.ProcessResult versionResult =
        await io.Process.run('xcrun', ['simctl', 'boot', '$id']);

    if (versionResult.exitCode != 0) {
      throw Exception('Failed to boot iOS simulators with id: $id.');
    }
    this._booted = true;
    return;
  }

  /// Shuts down the iOS Simulator using the simulator [id].
  ///
  /// Uses `xcrun simctl shutdown` command to boot an iOS Simulator.
  ///
  /// If the simulator is not booted, the command will fail.
  Future<void> shutdown() async {
    final io.ProcessResult versionResult =
        await io.Process.run('xcrun', ['simctl', 'shutdown', '$id']);

    if (versionResult.exitCode != 0) {
      throw Exception('Failed to shutdown iOS simulators with id: $id.');
    }

    this._booted = false;
    return;
  }

  @override
  String toString() {
    return 'iOS Simulator id: $id status: $booted';
  }
}
