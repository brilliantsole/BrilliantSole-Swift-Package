//
//  BSVibrationWaveformEffectSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import OSLog
import UkatonMacros

public typealias BSVibrationWaveformEffectDelay = UInt16

@StaticLogger(disabled: true)
public struct BSVibrationWaveformEffectSegment: BSVibrationSegment {
    public static var type: BSVibrationType { .waveformEffect }

    public var segmentType: BSVibrationWaveformEffectSegmentType
    public var effect: BSVibrationWaveformEffect
    public var delay: BSVibrationWaveformEffectDelay {
        didSet {
            delay = min(delay, maxDelay)
            delay -= delay % Self.DelayStep
        }
    }

    public var loopCount: UInt8 {
        didSet {
            loopCount = min(loopCount, maxLoopCount)
        }
    }

    public static let MaxDelay: BSVibrationWaveformEffectDelay = 1270
    public var maxDelay: UInt16 { Self.MaxDelay }

    public static let DelayStep: UInt16 = 10
    public var delayStep: UInt16 { Self.DelayStep }

    public static let MaxLoopCount: UInt8 = 3
    public var maxLoopCount: UInt8 { Self.MaxLoopCount }

    public init(effect: BSVibrationWaveformEffect, loopCount: UInt8 = 0) {
        self.segmentType = .effect
        self.effect = effect
        self.delay = 0
        self.loopCount = min(loopCount, Self.MaxLoopCount)
    }

    public init(delay: UInt16, loopCount: UInt8 = 0) {
        self.segmentType = .delay
        self.effect = .none
        self.delay = min(delay, Self.MaxDelay)
        self.loopCount = min(loopCount, Self.MaxLoopCount)

        self.delay -= self.delay % Self.DelayStep
    }

    var bytes: [UInt8] {
        switch segmentType {
        case .effect:
            logger?.debug("Creating waveform effect segment with effect: \(effect.name)")
            return [effect.rawValue]
        case .delay:
            logger?.debug("Creating delay segment with delay: \(delay)ms")
            return [UInt8(1 << 7 | (delay / Self.DelayStep))]
        }
    }

    public var data: Data {
        .init(bytes)
    }
}
