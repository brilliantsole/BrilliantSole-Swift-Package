//
//  BKVibrationType.swift
//  BrilliantKit
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

@EnumName
public enum BKVibrationType: UInt8 {
    case waveformEffect
    case waveform

    public var maxSequenceLength: Int {
        switch self {
        case .waveformEffect:
            8
        case .waveform:
            20
        }
    }
}
