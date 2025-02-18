//
//  BSDeviceType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSDeviceType: UInt8, BSEnum {
    case leftInsole
    case rightInsole

    public var isInsole: Bool {
        switch self {
        case .leftInsole, .rightInsole:
            true
        default:
            false
        }
    }

    public var insoleSide: BSInsoleSide? {
        switch self {
        case .leftInsole:
            .left
        case .rightInsole:
            .right
        default:
            nil
        }
    }
}
