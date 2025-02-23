//
//  BSVibrationWaveformSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

public typealias BSVibrationWaveformSegmentAmplitude = Float
public typealias BSVibrationWaveformSegmentDuration = UInt16

public struct BSVibrationWaveformSegment: BSVibrationSegment {
    public static var type: BSVibrationType { .waveform }

    public var amplitude: BSVibrationWaveformSegmentAmplitude {
        didSet {
            amplitude = max(0.0, min(amplitude, 1.0))
            amplitude = round(amplitude * BSVibrationWaveformSegmentAmplitude(Self.AmplitudeNumberOfSteps)) / BSVibrationWaveformSegmentAmplitude(Self.AmplitudeNumberOfSteps)
        }
    }

    public var duration: BSVibrationWaveformSegmentDuration {
        didSet {
            duration = min(duration, maxDuration)
            duration -= duration % Self.DurationStep
        }
    }

    public static let MaxDuration: BSVibrationWaveformSegmentDuration = 2550
    public var maxDuration: BSVibrationWaveformSegmentDuration { Self.MaxDuration }

    public static let DurationStep: BSVibrationWaveformSegmentDuration = 10
    public var durationStep: BSVibrationWaveformSegmentDuration { Self.DurationStep }

    public static let AmplitudeNumberOfSteps: UInt8 = 127
    public var amplitudeNumberOfSteps: UInt8 { Self.AmplitudeNumberOfSteps }

    public static var AmplitudeStep: Float { 1.0 / Float(AmplitudeNumberOfSteps) }
    public var amplitudeStep: Float { Self.AmplitudeStep }

    public init(amplitude: BSVibrationWaveformSegmentAmplitude, duration: BSVibrationWaveformSegmentDuration) {
        self.amplitude = max(0.0, min(amplitude, 1.0))
        self.duration = min(duration, Self.MaxDuration)

        // Apply rounding and clamping
        self.amplitude = round(self.amplitude * BSVibrationWaveformSegmentAmplitude(Self.AmplitudeNumberOfSteps)) / BSVibrationWaveformSegmentAmplitude(Self.AmplitudeNumberOfSteps)
        self.duration -= self.duration % Self.DurationStep
    }

    var bytes: [UInt8] {
        [UInt8(amplitude * BSVibrationWaveformSegmentAmplitude(Self.AmplitudeNumberOfSteps)), UInt8(duration / Self.DurationStep)]
    }

    public var data: Data {
        .init(bytes)
    }
}
