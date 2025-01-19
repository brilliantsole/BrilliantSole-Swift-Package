//
//  BSVibrationConfiguration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/18/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger
public struct BSVibrationConfiguration {
    public var locations: [BSVibrationLocationFlag]

    public var type: BSVibrationType

    public var waveformEffectSegments: BSVibrationWaveformEffectSegments = [] {
        didSet {
            waveformEffectSegments = waveformEffectSegments.getMaxLengthPrefix()
        }
    }

    public var waveformEffectSegmentsLoopCount: UInt8 = 0 {
        didSet {
            waveformEffectSegmentsLoopCount = min(waveformEffectSegmentsLoopCount, BSVibrationWaveformEffectSegments.maxWaveformEffectSegmentsLoopCount)
        }
    }

    public var waveformSegments: BSVibrationWaveformSegments = [] {
        didSet {
            waveformSegments = waveformSegments.getMaxLengthPrefix()
        }
    }

    init(locations: [BSVibrationLocationFlag], waveformEffectSegments: BSVibrationWaveformEffectSegments, waveformEffectsegmentsLoopCount: UInt8) {
        self.locations = locations
        self.waveformEffectSegments = waveformEffectSegments
        self.type = .waveformEffect
        self.waveformEffectSegmentsLoopCount = waveformEffectsegmentsLoopCount
    }

    init(locations: [BSVibrationLocationFlag], waveformSegments: BSVibrationWaveformSegments) {
        self.locations = locations
        self.waveformSegments = waveformSegments
        self.type = .waveform
    }

    func getData() -> Data {
        var data: Data = .init()
        guard locations.count > 0 else {
            logger.warning("no locations specified - returning empty data")
            return data
        }

        let segmentsData = getSegmentsData()
        guard segmentsData.count > 0 else {
            logger.warning("empty segmentsData - returning empty data")
            return data
        }

        data.append(contentsOf: [type.rawValue])
        data.append(contentsOf: [locations.rawValue])
        data.append(segmentsData)

        logger.debug("serialized \(type.name) vibration: \(data.debugDescription)")
        return data
    }

    func getSegmentsData() -> Data {
        switch type {
        case .waveformEffect:
            waveformEffectSegments.getData(waveformEffectSequenceLoopCount: waveformEffectSegmentsLoopCount)
        case .waveform:
            waveformSegments.getData()
        }
    }
}
