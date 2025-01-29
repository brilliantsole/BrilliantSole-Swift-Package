//
//  BSDeviceInformationType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSDeviceInformationType: CaseIterable, Sendable {
    case manufacturerNameString
    case modelNumberString
    case softwareRevisionString
    case hardwareRevisionString
    case firmwareRevisionString
    case pnpId
    case serialNumberString
    case systemIdString
}
