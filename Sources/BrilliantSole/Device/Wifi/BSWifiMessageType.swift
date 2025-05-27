//
//  BSWifiMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/25/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSWifiMessageType: UInt8, BSEnum {
    case isWifiAvailable
    case getWifiSSID
    case setWifiSSID
    case getWifiPassword
    case setWifiPassword
    case getWifiConnectionEnabled
    case setWifiConnectionEnabled
    case isWifiConnected
    case ipAddress
    case isWifiSecure
}
