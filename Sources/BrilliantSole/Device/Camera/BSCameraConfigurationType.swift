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

    public var range: ClosedRange<BSCameraConfigurationValue> {
        switch self {
        case .resolution:
            100...720
        case .qualityFactor:
            15...60
        case .shutter:
            4...16383
        case .gain:
            1...248
        case .redGain, .blueGain, .greenGain:
            0...1023
        default:
            BSCameraConfigurationValue.min...BSCameraConfigurationValue.max
        }
    }

    public var step: UInt16 {
        switch self {
        case .resolution:
            20
        case .qualityFactor:
            5
        case .shutter:
            200
        case .gain:
            10
        case .redGain, .blueGain, .greenGain:
            20
        default:
            1
        }
    }
}
