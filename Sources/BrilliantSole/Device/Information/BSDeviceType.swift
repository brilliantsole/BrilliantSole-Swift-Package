//
//  BSDeviceType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName
public enum BSDeviceType: UInt8, BSEnum {
    case leftInsole
    case rightInsole

    var isInsole: Bool {
        switch self {
        case .leftInsole, .rightInsole:
            true
        default:
            false
        }
    }

    var insoleSide: BSInsoleSide? {
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
