//
//  BSBatteryMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSBatteryMessageType: UInt8, BSEnum {
    case getIsBatteryCharging
    case getBatteryCurrent
}
