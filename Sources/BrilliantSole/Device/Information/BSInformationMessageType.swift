//
//  BSInformationMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSInformationMessageType: UInt8, CaseIterable, Sendable {
    case getMtu
    case getId
    case getName
    case setName
    case getDeviceType
    case setDeviceType
    case getCurrentTime
    case setCurrentTime
}
