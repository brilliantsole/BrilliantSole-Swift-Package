//
//  BSConnectionType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSConnectionType: CaseIterable, Sendable {
    case ble
    case udp
}
