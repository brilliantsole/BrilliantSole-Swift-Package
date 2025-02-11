//
//  BSDevicePairConnectionStatus.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/10/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSDevicePairConnectionStatus: BSNamedEnum, CaseIterable, Sendable {
    case notConnected
    case halfConnected
    case fullyConnected
}
