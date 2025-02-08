//
//  BSVibrationWaveformEffectSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public struct BSVibrationWaveformEffectSegment: BSVibrationSegment {
    public static var type: BSVibrationType { .waveformEffect }

    var segmentType: BSVibrationWaveformEffectSegmentType
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
        self.segmentType = .effect
        self.effect = effect
        self.delay = 0
        self.loopCount = min(loopCount, Self.maxLoopCount)
    }

    init(delay: UInt16, loopCount: UInt8 = 0) {
        self.segmentType = .delay
        self.effect = .none
        self.delay = min(delay, Self.maxDelay)
        self.loopCount = min(loopCount, Self.maxLoopCount)

        self.delay -= self.delay % 10
    }

    var bytes: [UInt8] {
        switch segmentType {
        case .effect:
            logger?.debug("Creating waveform effect segment with effect: \(effect.name)")
            return [effect.rawValue]
        case .delay:
            logger?.debug("Creating delay segment with delay: \(delay)ms")
            return [UInt8(1 << 7 | (delay / 10))]
        }
    }

    public var data: Data {
        .init(bytes)
    }
}
