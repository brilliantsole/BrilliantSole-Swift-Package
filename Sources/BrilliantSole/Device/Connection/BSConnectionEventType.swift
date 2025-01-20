//
//  BSConnectionEventType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSConnectionEventType: UInt8, CaseIterable, Sendable {
    case connectionStatus
    case isConnected
}
