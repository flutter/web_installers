## What is Simulators

Simulators is a set of libraries for controlling mobile simulators/emulators. Currently there is support for iOS Simulators.

## What can I use Simulators for

Currently only `IosSimulatorManager` is implemented. It can be used for:

1. **create**: Creates an iOS Simulator for given iOS version and phone name:

```
IosSimulatorManager simulatorManager = IosSimulatorManager();
IosSimulator id =
    await simulatorManager.createSimulator(13, 5, 'iPad mini 4');
```

2. **boot**: Boots the iOS Simulator that's id is given:

```
IosSimulatorManager simulatorManager = IosSimulatorManager();
await simulatorManager.bootSimulator('D8074C8B-35A5-4DA5-9AB2-4CE738A5E5FC' /* Simulator id*/);
```

3. **shutdown**: Shutsdown the iOS Simulator that's id is given:

```
IosSimulatorManager simulatorManager = IosSimulatorManager();
await simulatorManager.shutdownSimulator('D8074C8B-35A5-4DA5-9AB2-4CE738A5E5FC'/* Simulator id*/);
```

4. **getInformation**: Get the id and status of a simulator, given the iOS version and the phone name:

```
IosSimulatorManager simulatorManager = IosSimulatorManager();
IosSimulator result =
    await simulatorManager.getSimulatorInfo(13, 1, 'iPhone 11 Pro');
```

5. **list**: List the existing simulators for a given iOS version:

```
IosSimulatorManager simulatorManager = IosSimulatorManager();
String output = await simulatorManager.listExistingSimulators(13,3);
```
