@testable import BrilliantSole
import Combine
import Foundation
import Testing

class CancellablesStore {
    var cancellables: Set<AnyCancellable> = []
}

nonisolated(unsafe) var tfliteFile: BSTfliteFile = .init(
    fileName: "model",
    bundle: .module,
    modelName: "gestures",
    sensorTypes: [.gyroscope, .linearAcceleration],
    task: .classification,
    sensorRate: ._10ms,
    captureDelay: 500,
    classes: ["idle", "kick", "stomp", "tap"]
)

struct BSTests {
    @Test func enumStringsTest() async throws {
        let enumStrings = BSTxRxMessageUtils.enumStrings
        enumStrings.enumerated().forEach { print("\($0): \($1)") }
    }

    @Test func connectionEnumStringsTest() async throws {
        let enumStrings = BSConnectionMessageUtils.enumStrings
        enumStrings.enumerated().forEach { print("\($0): \($1)") }
    }

    @Test func deviceEventEnumStringsTest() async throws {
        let enumStrings = BSDeviceEventMessageUtils.enumStrings
        enumStrings.enumerated().forEach { print("\($0): \($1)") }
    }

    @Test func parseConfigurationTest() async throws {
        let configuration: BSSensorConfiguration = [.acceleration: ._80ms, .gameRotation: ._20ms]
        print("sensorConfiguration: \(configuration)")
        let configurationData = configuration.getData()
        print("sensorConfigurationData: \(configurationData.bytes)")
        let parsedConfiguration = BSSensorConfiguration.parse(configurationData)
        #expect(parsedConfiguration != nil)
        print("parsedConfiguration: \(String(describing: parsedConfiguration!))")
        #expect(configuration == parsedConfiguration)
    }

    @Test func loadTfliteFileTest() async throws {
        let data = tfliteFile.getFileData()
        #expect(data != nil)
        print("checksum: \(data!.crc32())")
        #expect(data!.crc32() == 200001559)
    }

    @Test func vibrationWaveformTest() async throws {
        let configuration: BSVibrationConfiguration = .init(locations: [.front, .rear], waveformSegments: [.init(amplitude: 0.5, duration: 100)])
        let configurationData = configuration.getData()
        #expect(configurationData != nil)
        print("vibrationWaveform data: \(configurationData!.bytes)")
    }

    @Test func vibrationWaveformEffectTest() async throws {
        let configuration: BSVibrationConfiguration = .init(locations: [.front, .rear], waveformEffectSegments: [.init(effect: .alert1000ms, loopCount: 0)], loopCount: 2)
        let configurationData = configuration.getData()
        #expect(configurationData != nil)
        print("vibrationWaveformEffects data: \(configurationData!.bytes)")
    }

    @Test func bleUtilsTest() async throws {
        for service in BSBleServiceUUID.allCases {
            print("service \(service), uuid \(service.uuid), characteristics: \(service.characteristics)")
        }
        for characteristic in BSBleCharacteristicUUID.allCases {
            print("characteristic \(characteristic), uuid \(characteristic.uuid), service: \(characteristic.service)")
        }
    }

    var cancellablesStore = CancellablesStore()

    @Test func discoveredDeviceJsonTest() async throws {
        let discoveredDeviceJson = BSDiscoveredDeviceJson(jsonString: "{\"name\":\"Brilliant Sole\",\"bluetoothId\":\"0b68679a6951bda8ca8fe31356f4e189\",\"deviceType\":\"leftInsole\",\"rssi\":-46}")
        #expect(discoveredDeviceJson != nil)
        print(discoveredDeviceJson!)
        print("discoveredDeviceJson \(discoveredDeviceJson!), deviceType \(discoveredDeviceJson!.deviceType?.name ?? "nil")")
    }

    @Test func scanTest() async throws {
        BSBleScanner.shared.startScan()
        BSBleScanner.shared.discoveredDevicePublisher.sink { discoveredDevice in
            print("discoveredDevice \"\(discoveredDevice.name)\"")
        }.store(in: &cancellablesStore.cancellables)
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
        BSBleScanner.shared.stopScan()
    }

    func connectToDevice(withName name: String? = nil, onConnectedDevice: ((BSDevice) -> Void)? = nil) {
        var foundDevice = false
        print("starting scan")
        BSBleScanner.shared.startScan()
        BSBleScanner.shared.discoveredDevicePublisher.sink { [self] discoveredDevice in
            print("discoveredDevice \(discoveredDevice.name)")
            guard name == nil || discoveredDevice.name == name else { return }
            guard !foundDevice else { return }
            foundDevice = true
            BSBleScanner.shared.stopScan()
            print("connecting to discoveredDevice \(discoveredDevice)")
            discoveredDevice.connect()
            let device = discoveredDevice.device
            device?.connectedPublisher.sink { _ in
                print("connected to device \"\(device!.name)\"")
                onConnectedDevice?(device!)
            }.store(in: &cancellablesStore.cancellables)
        }.store(in: &cancellablesStore.cancellables)
    }

    @Test func deviceConnectionTest() async throws {
        connectToDevice(onConnectedDevice: { device in
            device.notConnectedPublisher.sink { _ in
                print("disconnected from device \"\(device.name)\"")
            }.store(in: &cancellablesStore.cancellables)
            device.disconnect()
        })
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
    }

    @Test func deviceManagerTest() async throws {
        connectToDevice()
        BSDeviceManager.connectedDevicePublisher.sink { device in
            print("connectedDevice \(device.name) added")
        }.store(in: &cancellablesStore.cancellables)
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
    }

    @Test func deviceSensorDataTest() async throws {
        connectToDevice(withName: "Right", onConnectedDevice: { device in
            // device.setSensorRate(sensorType: .orientation, sensorRate: ._100ms)
            var sensorConfiguration: BSSensorConfiguration = [.deviceOrientation: ._100ms, .pressure: ._100ms]
            device.setSensorConfiguration(sensorConfiguration)
            device.pressureDataPublisher.sink { pressureData, _ in
                for (index, sensor) in pressureData.sensors.enumerated() {
                    print("#\(index): \(sensor.rawValue)")
                }
            }.store(in: &cancellablesStore.cancellables)
            device.orientationPublisher.sink { orientation, _ in
                print("orientation \(orientation.eulerAngles(order: .xyz))")
            }.store(in: &cancellablesStore.cancellables)
        })
        try await Task.sleep(nanoseconds: 20 * 1_000_000_000)
    }

    @Test func deviceVibrationTest() async throws {
        connectToDevice(withName: "Right 3", onConnectedDevice: { device in
            if true {
                device.triggerVibration([.init(locations: .all, waveformEffectSegments: [.init(effect: .doubleClick100)], loopCount: 2)])
            }
            else {
                device.triggerVibration([.init(locations: .all, waveformSegments: [
                    .init(amplitude: 1, duration: 300),
                    .init(amplitude: 0, duration: 500),
                    .init(amplitude: 1, duration: 500)
                ])])
            }
        })
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
    }

    @Test func deviceTfliteTest() async throws {
        connectToDevice(withName: "Right 3", onConnectedDevice: { device in
            device.sendTfliteModel(&tfliteFile)

            device.isTfliteReadyPublisher.sink { isTfliteReady in
                if isTfliteReady {
                    print("tflite is ready")
                    device.enableTfliteInferencing()
                }
            }.store(in: &cancellablesStore.cancellables)

            device.tfliteClassificationPublisher.sink { classification in
                print("detected \"\(classification.name)\" gesture")
            }.store(in: &cancellablesStore.cancellables)
        })
        try await Task.sleep(nanoseconds: 1 * 60 * 1_000_000_000)
    }

    @Test func devicePairTest() async throws {
        let devicePair: BSDevicePair = .shared
        BSBleScanner.shared.startScan()
        BSBleScanner.shared.discoveredDevicePublisher.sink { discoveredDevice in
            print("connecting to discoveredDevice \(discoveredDevice)")
            let device = discoveredDevice.connect()
        }.store(in: &cancellablesStore.cancellables)
        devicePair.isFullyConnectedPublisher.sink { isFullyConnected in
            if isFullyConnected {
                BSBleScanner.shared.stopScan()
                devicePair.setSensorRate(sensorType: .pressure, sensorRate: ._40ms)
            }
        }.store(in: &cancellablesStore.cancellables)
        try await Task.sleep(nanoseconds: 20 * 1_000_000_000)
    }

    @Test func udpClientTest() async throws {
        let udpClient = BSUdpClient.shared
        udpClient.connectedPublisher.sink { _ in
            print("connected")
            if udpClient.isScanningAvailable {
                print("startScan")
                udpClient.startScan()
            }
        }.store(in: &cancellablesStore.cancellables)
        var device: BSDevice?

        udpClient.discoveredDevicePublisher.sink { discoveredDevice in
            return
            guard device == nil else { return }
            print("connecting to discoveredDevice \(discoveredDevice.name)")
            discoveredDevice.connect()
            device = discoveredDevice.device
            device?.connectedPublisher.sink { _ in
                udpClient.stopScan()
                device?.setSensorRate(sensorType: .acceleration, sensorRate: ._100ms)
            }.store(in: &cancellablesStore.cancellables)
        }.store(in: &cancellablesStore.cancellables)

        udpClient.discoveredDevicesPublisher.sink { discoveredDevices in
            print("discovered \(discoveredDevices.count) devices")
        }.store(in: &cancellablesStore.cancellables)
        udpClient.connect()
        try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
    }

    #if os(macOS)
        @Test func firmwareTest() async throws {
            var didUpgradeFirmware = false
            connectToDevice(withName: "Brilliant Sole", onConnectedDevice: { device in
                guard device.canUpgradeFirmware else {
                    print("cannot update firmware")
                    return
                }
                guard !didUpgradeFirmware else {
                    print("already upgraded firmware")
                    return
                }
                device.firmwareUpgradeDidCompletePublisher.sink { _ in
                    print("firmware updated successfully")
                    didUpgradeFirmware = true
                }.store(in: &cancellablesStore.cancellables)
                print("updating firmware...")
                device.upgradeFirmware(fileName: "firmware", fileExtension: "bin", bundle: .module)
            })
            try await Task.sleep(nanoseconds: 3 * 60 * 1_000_000_000)
        }
    #endif
}
