//
//  BSDeviceInformationType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSDeviceInformationType: CaseIterable, Sendable {
    case manufacturerName
    case modelNumber
    case softwareRevision
    case hardwareRevision
    case firmwareRevision
    case pnpId
    case serialNumber
}
