@testable import BrilliantSole
import Testing

struct BSSensorConfigurationTests {
    @Test func parseConfigurationTest() async throws {
        let configuration: BSSensorConfiguration = [.acceleration: ._80ms, .gameRotation: ._20ms]
        print("sensorConfiguration: \(configuration)")
        let configurationData = configuration.getData()
        print("sensorConfigurationData: \(configurationData.bytes)")
        let parsedConfiguration = BSSensorConfiguration.parse(data: configurationData)
        #expect(parsedConfiguration != nil)
        print("parsedConfiguration: \(String(describing: parsedConfiguration))")
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
