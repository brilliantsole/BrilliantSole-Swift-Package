//
//  BSDeviceInformationType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSDeviceInformationType: BSNamedEnum, CaseIterable, Sendable {
    case manufacturerNameString
    case modelNumberString
    case softwareRevisionString
    case hardwareRevisionString
    case firmwareRevisionString
    case pnpId
    case serialNumberString

    var isRequired: Bool {
        switch self {
            case .pnpId:
                false
            default:
                true
        }
    }
}
