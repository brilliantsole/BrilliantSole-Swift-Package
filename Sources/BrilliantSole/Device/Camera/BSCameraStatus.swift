//
//  BSCameraStatus.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/27/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSCameraStatus: UInt8, BSEnum {
    case idle
    case focusing
    case takingPicture
    case asleep
}
