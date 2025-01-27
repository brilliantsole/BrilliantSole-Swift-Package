@testable import BrilliantSole
import Testing

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
        @Test func discoveredDeviceJsonTest() async throws {
            let discoveredDeviceJson = BSDiscoveredDeviceJson(jsonString: "{\"name\":\"Brilliant Sole\",\"bluetoothId\":\"0b68679a6951bda8ca8fe31356f4e189\",\"deviceType\":\"leftInsole\",\"rssi\":-46}")
            #expect(discoveredDeviceJson != nil)
            print(discoveredDeviceJson!)
            print("discoveredDeviceJson \(discoveredDeviceJson!), deviceType \(discoveredDeviceJson!.deviceType?.name ?? "nil")")
        }
    }
}
