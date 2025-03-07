//
//  BSFileTransferDirection.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSFileTransferDirection: UInt8, BSEnum {
    case sending
    case receiving
}
