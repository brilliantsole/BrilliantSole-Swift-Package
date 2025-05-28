//
//  BSCameraConfigurationType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/27/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSCameraConfigurationType: UInt8, BSEnum {
    case resolution
    case qualityFactor
    case shutter
    case gain
    case redGain
    case greenGain
    case blueGain
}

// FILL - add min/max value range
