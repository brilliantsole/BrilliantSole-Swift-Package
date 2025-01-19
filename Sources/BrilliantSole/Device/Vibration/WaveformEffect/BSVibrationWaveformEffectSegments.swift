//
//  BSVibrationWaveformEffectSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation

public typealias BSVibrationWaveformEffectSegments = [BSVibrationWaveformEffectSegment]

public extension Array where Element == BSVibrationWaveformEffectSegment {
    var type: BSVibrationType { .waveformEffect }

    func getData(waveformEffectSequenceLoopCount: UInt8) -> Data {
        var data: Data = .init()

        var hasAtLeast1WaveformEffectWithANonzeroLoopCount = false
        for index in 0 ..< Swift.min(count, type.maxSegmentsLength) {
            if self[index].loopCount != 0 {
                hasAtLeast1WaveformEffectWithANonzeroLoopCount = true
                break
            }
        }
        var includeAllWaveformEffectSegments = hasAtLeast1WaveformEffectWithANonzeroLoopCount || waveformEffectSequenceLoopCount != 0

        data += prefix(type.maxSegmentsLength).flatMap { $0.data }
        // FILL
        return data
    }

    static var maxWaveformEffectSegmentsLoopCount: UInt8 { 6 }
}
