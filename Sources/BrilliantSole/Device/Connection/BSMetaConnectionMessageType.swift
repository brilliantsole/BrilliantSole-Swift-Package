//
//  BSMetaConnectionMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSMetaConnectionMessageType: UInt8, BSEnum {
    case rx
    case tx
}
