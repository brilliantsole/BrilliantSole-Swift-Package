//
//  BSConnectionType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSConnectionType: BSNamedEnum, CaseIterable, Sendable {
    case ble
    case udpClient

    public var scanner: BSScanner {
        switch self {
        case .ble:
            BSBleScanner.shared
        case .udpClient:
            BSUdpClient.shared
        }
    }
}
