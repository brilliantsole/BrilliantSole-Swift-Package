//
//  BSSmpEventType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSSmpEventType: UInt8, BSEnum {
    case firmwareImages
    case firmwareUploadProgress
    case firmwareStatus
    case firmwareUploadComplete
}
