//
//  VibrationWaveformSegment.swift
//  BrilliantKit
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation

struct BKVibrationWaveformSegment {
    var amplitude: Float {
        didSet {
            amplitude = max(0.0, min(amplitude, 1.0))
            amplitude = round(amplitude * Float(Self.amplitudeNumberOfSteps)) / Float(Self.amplitudeNumberOfSteps)
        }
    }

    var duration: UInt16 {
        didSet {
            duration = min(duration, Self.maxDuration)
            duration -= duration % 10
        }
    }

    static let maxDuration: UInt16 = 2550
    static let amplitudeNumberOfSteps: UInt8 = 127

    init(amplitude: Float, duration: UInt16) {
        self.amplitude = max(0.0, min(amplitude, 1.0))
        self.duration = min(duration, Self.maxDuration)

        // Apply rounding and clamping
        self.amplitude = round(self.amplitude * Float(Self.amplitudeNumberOfSteps)) / Float(Self.amplitudeNumberOfSteps)
        self.duration -= self.duration % 10
    }
}
