//
//  BSConnectionEventType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSConnectionEventType: UInt8, BSEnum {
    case connectionStatus
    case isConnected
}
