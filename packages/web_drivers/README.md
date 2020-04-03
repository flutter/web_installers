**To install and start Chrome Driver.**

```dart lib/web_driver_installer.dart chromedriver```

**If one wants to keep driver running after terminal shutdown add &**

```dart lib/web_driver_installer.dart chromedriver &```

**Chrome Driver versions are stored in driver_version.yaml.yaml. Driver version can also be given as an argument.**

```dart lib/web_driver_installer.dart chromedriver --driver-version="78.0.3904.105"```

**There might be an already installed version of the driver. If one wants to override they can use the following flag, otherwise the existing driver is used.**

```dart lib/web_driver_installer.dart chromedriver --always-install```

**To only install the chrome driver**

```dart lib/web_driver_installer.dart chromedriver --install-only```

**To enable and start Safari Driver.**

```dart lib/web_driver_installer.dart safaridriver```

**Start a specific version of the driver.**
This will end with an error if the exiting version differs from the system version. This is useful for failing fast when running on CI environments to see if the expected version is installed.

```dart lib/web_driver_installer.dart safaridriver --driver-version="13.0.5"```

**No-options also currently defaults to install and start Chrome Driver. It will be deprecated soon.**

```dart lib/web_driver_installer.dart &```
