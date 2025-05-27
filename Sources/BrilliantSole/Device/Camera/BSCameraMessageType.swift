//
//  BSCameraMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/27/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSCameraMessageType: UInt8, BSEnum {
    case cameraStatus
    case cameraCommand
    case getCameraConfiguration
    case setCameraConfiguration
    case cameraData
}
