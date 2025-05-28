//
//  BSCameraCommand.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/27/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSCameraCommand: UInt8, BSEnum {
    case focus
    case takePicture
    case stop
    case sleep
    case wake
}
