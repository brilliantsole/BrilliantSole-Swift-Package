//
//  BSVibrationType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

@EnumName
public enum BSVibrationType: UInt8, CaseIterable {
    case waveformEffect
    case waveform

    public var maxSegmentsLength: Int {
        switch self {
        case .waveformEffect:
            8
        case .waveform:
            20
        }
    }
}
