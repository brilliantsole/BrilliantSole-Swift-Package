//
//  BSVibrationConfiguration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/18/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public struct BSVibrationConfiguration {
    public var locations: [BSVibrationLocationFlag]

    public var type: BSVibrationType

    public var waveformEffectSegments: BSVibrationWaveformEffectSegments = [] {
        didSet {
            waveformEffectSegments = waveformEffectSegments.getMaxLengthPrefix()
        }
    }

    /// only applicable to "waveformEffect" type
    public var loopCount: UInt8 = 0 {
        didSet {
            loopCount = min(loopCount, BSVibrationWaveformEffectSegments.MaxLoopCount)
        }
    }

    public var waveformSegments: BSVibrationWaveformSegments = [] {
        didSet {
            waveformSegments = waveformSegments.getMaxLengthPrefix()
        }
    }

    public init(locations: [BSVibrationLocationFlag], waveformEffectSegments: BSVibrationWaveformEffectSegments, loopCount: UInt8 = 0) {
        self.locations = locations
        self.waveformEffectSegments = waveformEffectSegments
        self.type = .waveformEffect
        self.loopCount = loopCount
    }

    public init(locations: [BSVibrationLocationFlag], waveformSegments: BSVibrationWaveformSegments) {
        self.locations = locations
        self.waveformSegments = waveformSegments
        self.type = .waveform
    }

    func getData() -> Data? {
        var data: Data = .init()
        guard locations.count > 0 else {
            logger?.warning("no locations specified - returning nil")
            return nil
        }

        let segmentsData = getSegmentsData()
        guard segmentsData.count > 0 else {
            logger?.warning("empty segmentsData - returning nil")
            return nil
        }

        logger?.debug("vibration type \(type.data.bytes) (\(type.name), locations \(locations.data.bytes), segmentsData \(segmentsData.bytes)")

        data += locations.data
        data += type.data
        data.append(UInt8(segmentsData.count))
        data += segmentsData

        logger?.debug("serialized \(type.name) vibration: \(data.debugDescription) \(data.bytes)")
        return data
    }

    private func getSegmentsData() -> Data {
        switch type {
        case .waveformEffect:
            waveformEffectSegments.getData(waveformEffectSequenceLoopCount: loopCount)
        case .waveform:
            waveformSegments.getData()
        }
    }
}

public typealias BSVibrationConfigurations = [BSVibrationConfiguration]
