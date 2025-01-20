//
//  BSConnectionStatus.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSConnectionStatus {
    case notConnected
    case connecting
    case connected
    case disconnecting
}
