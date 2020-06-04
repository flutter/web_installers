## What is Simulators

Simulators is a set of libraries for controlling mobile simulators/emulators.
Currently there is support for iOS Simulators.

## What can I use Simulators library for

Currently only iOS is supported. There are two main classes `IosSimulator` and
`IosSimulatorManager`. `IosSimulatorManager` can be used for accesing `IosSimulator`
instances.

1. Creating an iOS Simulator for given iOS version and phone name:

```
IosSimulatorManager simulatorManager = IosSimulatorManager();
IosSimulator simulator =
    await simulatorManager.createSimulator(13, 5, 'iPad mini 4');
```

2. Get an existing simulator, given the iOS version and the phone name:


```
IosSimulatorManager simulatorManager = IosSimulatorManager();
IosSimulator simulator =
    await simulatorManager.getSimulator(13, 1, 'iPhone 11 Pro');
```

`IosSimulator` can be used to boot and shutdown a simulator. It's constructor is private.
It can be created using `IosSimulatorManager` methods.

1. **boot**: Boots the iOS Simulator:

```
IosSimulator simulator =
    await simulatorManager.getSimulator(13, 1, 'iPhone 11 Pro');
await simulator.boot();
```

2. **shutdown**: Shutsdown the iOS Simulator that's id is given:

```
await simulator.shutdown();
```
