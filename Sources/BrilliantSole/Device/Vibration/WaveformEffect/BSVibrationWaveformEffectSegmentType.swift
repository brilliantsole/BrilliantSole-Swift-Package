//
//  BSVibrationWaveformEffectSegmentType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSVibrationWaveformEffectSegmentType: UInt8, BSEnum {
    case effect
    case delay
}
