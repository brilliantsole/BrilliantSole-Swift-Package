//
//  BSFileTransferCommand.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSFileTransferCommand: UInt8, BSEnum {
    case send
    case receive
    case cancel
}
