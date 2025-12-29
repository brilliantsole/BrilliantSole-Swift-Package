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

    case autoWhiteBalanceEnabled
    case autoGainEnabled
    case exposure
    case autoExposureEnabled
    case autoExposureLevel
    case brightness
    case saturation
    case contrast
    case sharpness

    public var range: ClosedRange<BSCameraConfigurationValue> {
        switch self {
        case .resolution:
            96...2560
        case .qualityFactor:
            0...100
        case .shutter:
            4...16383
        case .gain:
            0...248
        case .redGain, .blueGain, .greenGain:
            0...2047
        case .autoWhiteBalanceEnabled:
            0...1
        case .autoGainEnabled:
            0...1
        case .exposure:
            0...1200
        case .autoExposureEnabled:
            0...1
        case .autoExposureLevel:
            -4...4
        case .brightness:
            -3...3
        case .saturation:
            -4...4
        case .contrast:
            -3...3
        case .sharpness:
            -3...3
        default:
            0...1
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
        case .exposure:
            100
        default:
            1
        }
    }

    var dataType: any FixedWidthInteger.Type {
        switch self {
        case .autoExposureLevel,
             .brightness,
             .saturation,
             .contrast,
             .sharpness:
            Int16.self
        default:
            UInt16.self
        }
    }
}
