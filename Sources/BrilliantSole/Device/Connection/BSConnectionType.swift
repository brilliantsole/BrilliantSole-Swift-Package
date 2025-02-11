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
    case udp

    public var scanner: BSScanner {
        switch self {
        case .ble:
            BSBleScanner.shared
        case .udp:
            BSUdpClient.shared
        }
    }
}
