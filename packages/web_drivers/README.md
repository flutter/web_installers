```
# Chrome Driver versions are stored in driver_lock.yaml
# To install and start Chrome Driver.

dart lib/web_driver_installer.dart chromedriver &

# To only install the chrome driver

dart lib/web_driver_installer.dart chromedriver install-only

# No-options also currently defaults to install and start Chrome Driver.
# It will be deprecated soon.

dart lib/web_driver_installer.dart &
