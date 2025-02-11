//
//  BSSensorConfigurationMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSSensorConfigurationMessageType: UInt8, BSEnum {
    case getSensorConfiguration
    case setSensorConfiguration
}
