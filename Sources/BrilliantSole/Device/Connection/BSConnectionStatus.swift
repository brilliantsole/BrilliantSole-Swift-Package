//
//  BSConnectionStatus.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSConnectionStatus: BSNamedEnum, CaseIterable, Sendable {
    case notConnected
    case connecting
    case connected
    case disconnecting
}
