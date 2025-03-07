//
//  BSFileTransferEventType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSFileTransferEventType: UInt8, BSEnum {
    case fileTransferProgress
    case fileTransferComplete
    case fileReceived
}
