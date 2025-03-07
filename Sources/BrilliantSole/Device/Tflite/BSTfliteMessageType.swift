//
//  BSTfliteMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSTfliteMessageType: UInt8, BSEnum {
    case getTfliteName
    case setTfliteName
    case getTfliteTask
    case setTfliteTask
    case getTfliteSensorRate
    case setTfliteSensorRate
    case getTfliteSensorTypes
    case setTfliteSensorTypes
    case isTfliteReady
    case getTfliteCaptureDelay
    case setTfliteCaptureDelay
    case getTfliteThreshold
    case setTfliteThreshold
    case getTfliteInferencingEnabled
    case setTfliteInferencingEnabled
    case tfliteInference
}
