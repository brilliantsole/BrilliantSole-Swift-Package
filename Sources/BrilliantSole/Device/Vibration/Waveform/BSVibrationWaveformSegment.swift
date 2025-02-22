//
//  BSVibrationWaveformSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

public struct BSVibrationWaveformSegment: BSVibrationSegment {
    public static var type: BSVibrationType { .waveform }

    public var amplitude: Float {
        didSet {
            amplitude = max(0.0, min(amplitude, 1.0))
            amplitude = round(amplitude * Float(Self.AmplitudeNumberOfSteps)) / Float(Self.AmplitudeNumberOfSteps)
        }
    }

    public var duration: UInt16 {
        didSet {
            duration = min(duration, maxDuration)
            duration -= duration % 10
        }
    }

    public static let MaxDuration: UInt16 = 2550
    public var maxDuration: UInt16 { Self.MaxDuration }
    public static let AmplitudeNumberOfSteps: UInt8 = 127
    public var amplitudeNumberOfSteps: UInt8 { Self.AmplitudeNumberOfSteps }

    public init(amplitude: Float, duration: UInt16) {
        self.amplitude = max(0.0, min(amplitude, 1.0))
        self.duration = min(duration, Self.MaxDuration)

        // Apply rounding and clamping
        self.amplitude = round(self.amplitude * Float(Self.AmplitudeNumberOfSteps)) / Float(Self.AmplitudeNumberOfSteps)
        self.duration -= self.duration % 10
    }

    var bytes: [UInt8] {
        [UInt8(amplitude * Float(Self.AmplitudeNumberOfSteps)), UInt8(duration / 10)]
    }

    public var data: Data {
        .init(bytes)
    }
}
