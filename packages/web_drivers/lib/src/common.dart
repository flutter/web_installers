// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library common;

import 'dart:io' as io;

import 'package:yaml/yaml.dart';

/// Provides access to the contents of the `driver_lock.yaml` file.
class DriverLock {
  DriverLock._() {
    final io.File lockFile = io.File('driver_version.yaml');
    _configuration = loadYaml(lockFile.readAsStringSync()) as YamlMap;
  }

  /// Initializes the [DriverLock] singleton.
  static final DriverLock _singletonInstance = DriverLock._();

  /// The [DriverLock] singleton.
  static DriverLock get instance => _singletonInstance;

  YamlMap _configuration = YamlMap();
  YamlMap get configuration => _configuration;
}
