@testable import BrilliantSole
import Testing

struct BSVibrationTests {
    @Test mutating func vibrationWaveformTest() async throws {
        let configuration: BSVibrationConfiguration = .init(locations: [.front, .rear], waveformSegments: [.init(amplitude: 0.5, duration: 100)])
        let configurationData = configuration.getData()
        print(configurationData.bytes)
    }

    @Test mutating func vibrationWaveformEffectTest() async throws {
        let configuration: BSVibrationConfiguration = .init(locations: [.front, .rear], waveformEffectSegments: [.init(effect: .alert1000ms, loopCount: 0)], loopCount: 0)
        let configurationData = configuration.getData()
        print(configurationData.bytes)
    }
}
