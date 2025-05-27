
//
//  BSCameraEventType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/27/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSCameraEventType: UInt8, BSEnum {
    case cameraImageProgress
    case cameraImage
}
