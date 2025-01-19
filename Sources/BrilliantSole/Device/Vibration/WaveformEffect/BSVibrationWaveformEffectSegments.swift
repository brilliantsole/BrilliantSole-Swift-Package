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
        for index in 0 ..< Swift.min(count, maxLength) {
            if self[index].loopCount != 0 {
                hasAtLeast1WaveformEffectWithANonzeroLoopCount = true
                break
            }
        }

        let includeAllWaveformEffectSegments = hasAtLeast1WaveformEffectWithANonzeroLoopCount || waveformEffectSequenceLoopCount != 0

        for index in 0 ..< (includeAllWaveformEffectSegments ? maxLength : count) {
            if index >= count {
                data += BSVibrationWaveformEffect.none.data
                continue
            }
            data += self[index].data
        }

        for index in 0 ..< (includeAllWaveformEffectSegments ? maxLength : count) {
            if index == 0 || index == 4 { data += Data([0]) }

            var segmentLoopCount: UInt8 = 0
            if index < count { segmentLoopCount = self[index].loopCount }

            let bitOffset = 2 * (index % 4)
            data[data.count - 1] |= UInt8(segmentLoopCount << bitOffset)

            if index == 3 || index == 7 {}
        }

        let includeAllWaveformEffectSegmentLoopCounts = waveformEffectSequenceLoopCount != 0
        if includeAllWaveformEffectSegmentLoopCounts {
            data.append(contentsOf: [waveformEffectSequenceLoopCount])
        }

        return data
    }

    static var maxWaveformEffectSegmentsLoopCount: UInt8 { 6 }
}
