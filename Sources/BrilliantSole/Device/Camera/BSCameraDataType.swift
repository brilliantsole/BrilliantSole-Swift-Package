//
//  BSCameraDataType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/27/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSCameraDataType: UInt8, BSEnum {
    case headerSize
    case header
    case imageSize
    case image
    case footerSize
    case footer
}
