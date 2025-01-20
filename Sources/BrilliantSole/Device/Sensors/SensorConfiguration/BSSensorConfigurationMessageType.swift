//
//  BSSensorConfigurationMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSSensorConfigurationMessageType: UInt8, CaseIterable, Sendable {
    case getSensorConfiguration
    case setSensorConfiguration
}
