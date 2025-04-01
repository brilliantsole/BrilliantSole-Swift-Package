//
//  BSDevicePairType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 3/31/25.
//

import Foundation
import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSDevicePairType: BSNamedEnum, CaseIterable, Sendable {
    case insoles
    case gloves
}
