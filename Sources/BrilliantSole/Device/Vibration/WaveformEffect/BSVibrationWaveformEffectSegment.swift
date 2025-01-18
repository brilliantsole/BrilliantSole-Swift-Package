//
//  BSVibrationWaveformEffectSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

struct BSVibrationWaveformEffectSegment {
    var type: BSVibrationWaveformEffectSegmentType
    var effect: BSVibrationWaveformEffect
    var delay: UInt16 {
        didSet {
            delay = min(delay, Self.maxDelay)
            delay -= delay % 10
        }
    }

    var loopCount: UInt8 {
        didSet {
            loopCount = min(loopCount, Self.maxLoopCount)
        }
    }

    static let maxDelay: UInt16 = 1270
    static let maxLoopCount: UInt8 = 3

    init(effect: BSVibrationWaveformEffect, loopCount: UInt8 = 0) {
        self.type = .effect
        self.effect = effect
        self.delay = 0
        self.loopCount = min(loopCount, Self.maxLoopCount)
    }

    init(delay: UInt16, loopCount: UInt8 = 0) {
        self.type = .delay
        self.effect = .none
        self.delay = min(delay, Self.maxDelay)
        self.loopCount = min(loopCount, Self.maxLoopCount)

        self.delay -= self.delay % 10
    }
}
