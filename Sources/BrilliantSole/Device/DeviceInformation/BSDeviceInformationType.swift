//
//  BSDeviceInformationType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSDeviceInformationType: BSNamedEnum, CaseIterable, Sendable {
    case manufacturerNameString
    case modelNumberString
    case softwareRevisionString
    case hardwareRevisionString
    case firmwareRevisionString
    case serialNumberString
}
