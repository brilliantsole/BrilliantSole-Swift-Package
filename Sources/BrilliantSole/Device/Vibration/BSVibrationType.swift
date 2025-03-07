//
//  BSVibrationType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSVibrationType: UInt8, BSEnum {
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
