@testable import BrilliantSole
import Combine
import Foundation
import Testing

class CancellablesStore {
    var cancellables: Set<AnyCancellable> = []
}

enum BSTests {
    struct BSTxRxMessageTests {
        @Test func enumStringsTest() async throws {
            let enumStrings = BSTxRxMessageUtils.enumStrings
            enumStrings.enumerated().forEach { print("\($0): \($1)") }
        }
    }

    struct BSSensorConfigurationTests {
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
    }

    struct BSTfliteTests {
        @Test func loadTfliteFileTest() async throws {
            var tfliteFile: BSTfliteFile = .init(
                fileName: "model",
                modelName: "gestures",
                sensorTypes: [.linearAcceleration, .gyroscope],
                task: .classification,
                sensorRate: ._10ms,
                classes: ["idle", "kick", "stomp", "tap"]
            )
            let data = tfliteFile.getFileData(bundle: .module)
            #expect(data != nil)
            print("checksum: \(data!.crc32())")
            #expect(data!.crc32() == 200001559)
        }
    }

    struct BSVibrationTests {
        @Test func vibrationWaveformTest() async throws {
            let configuration: BSVibrationConfiguration = .init(locations: [.front, .rear], waveformSegments: [.init(amplitude: 0.5, duration: 100)])
            let configurationData = configuration.getData()
            print("vibrationWaveform data: \(configurationData.bytes)")
        }

        @Test func vibrationWaveformEffectTest() async throws {
            let configuration: BSVibrationConfiguration = .init(locations: [.front, .rear], waveformEffectSegments: [.init(effect: .alert1000ms, loopCount: 0)], loopCount: 0)
            let configurationData = configuration.getData()
            print("vibrationWaveformEffects data: \(configurationData.bytes)")
        }
    }

    struct BSBleTests {
        @Test func bleUtilsTest() async throws {
            for service in BSBleServiceUUID.allCases {
                print("service \(service), uuid \(service.uuid), characteristics: \(service.characteristics)")
            }
            for characteristic in BSBleCharacteristicUUID.allCases {
                print("characteristic \(characteristic), uuid \(characteristic.uuid), service: \(characteristic.service)")
            }
        }
    }

    struct BSScannerTests {
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

        @Test mutating func deviceConnectionTest() async throws {
            var foundDevice = false
            BSBleScanner.shared.startScan()
            BSBleScanner.shared.discoveredDevicePublisher.sink { [self] discoveredDevice in
                guard !foundDevice else { return }
                foundDevice = true
                BSBleScanner.shared.stopScan()
                print("connecting to discoveredDevice \(discoveredDevice)")
                let device = discoveredDevice.connect()
                device.connectedPublisher.sink { _ in
                    print("connected to device \"\(device.name)\"")
                    device.disconnect()
                }.store(in: &cancellablesStore.cancellables)
                device.notConnectedPublisher.sink { _ in
                    print("disconnected from device \"\(device.name)\"")
                }.store(in: &cancellablesStore.cancellables)
            }.store(in: &cancellablesStore.cancellables)
            try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            BSBleScanner.shared.stopScan()
        }

        @Test mutating func deviceSensorDataTest() async throws {
            
        }
    }
}
