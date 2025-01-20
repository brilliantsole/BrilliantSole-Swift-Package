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
    public var locations: [BSVibrationLocation]

    public var type: BSVibrationType

    public var waveformEffectSegments: BSVibrationWaveformEffectSegments = [] {
        didSet {
            waveformEffectSegments = waveformEffectSegments.getMaxLengthPrefix()
        }
    }

    public var loopCount: UInt8 = 0 {
        didSet {
            loopCount = min(loopCount, BSVibrationWaveformEffectSegments.maxWaveformEffectSegmentsLoopCount)
        }
    }

    public var waveformSegments: BSVibrationWaveformSegments = [] {
        didSet {
            waveformSegments = waveformSegments.getMaxLengthPrefix()
        }
    }

    init(locations: [BSVibrationLocation], waveformEffectSegments: BSVibrationWaveformEffectSegments, loopCount: UInt8) {
        self.locations = locations
        self.waveformEffectSegments = waveformEffectSegments
        self.type = .waveformEffect
        self.loopCount = loopCount
    }

    init(locations: [BSVibrationLocation], waveformSegments: BSVibrationWaveformSegments) {
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
            waveformEffectSegments.getData(waveformEffectSequenceLoopCount: loopCount)
        case .waveform:
            waveformSegments.getData()
        }
    }
}
