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
    sensorTypes: [.linearAcceleration, .gyroscope],
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

    func connectToDevice(withName name: String? = nil, onConnectedDevice: @escaping (BSDevice) -> Void) {
        var foundDevice = false
        BSBleScanner.shared.startScan()
        BSBleScanner.shared.discoveredDevicePublisher.sink { [self] discoveredDevice in
            guard name == nil || discoveredDevice.name == name else { return }
            guard !foundDevice else { return }
            foundDevice = true
            BSBleScanner.shared.stopScan()
            print("connecting to discoveredDevice \(discoveredDevice)")
            let device = discoveredDevice.connect()
            device.connectedPublisher.sink { _ in
                print("connected to device \"\(device.name)\"")
                onConnectedDevice(device)
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
        connectToDevice(onConnectedDevice: { _ in

        })
        // FIX
//        BSDeviceManager.connectedDevicesPublisher.sink { _ in
//
//        }.store(in: &cancellablesStore.cancellables)
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
    }

    @Test func deviceSensorDataTest() async throws {
        connectToDevice(withName: "Right 3", onConnectedDevice: { device in
            device.setSensorRate(sensorType: .pressure, sensorRate: ._100ms)
        })
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
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
        })
        try await Task.sleep(nanoseconds: 20 * 1_000_000_000)
    }
}
