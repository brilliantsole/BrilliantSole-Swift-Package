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
    case leftGlove
    case rightGlove
    case glasses
    case generic

    public var isInsole: Bool {
        switch self {
        case .leftInsole, .rightInsole:
            true
        default:
            false
        }
    }

    public var isGlove: Bool {
        switch self {
        case .leftGlove, .rightGlove:
            true
        default:
            false
        }
    }

    public var side: BSSide? {
        switch self {
        case .leftInsole, .leftGlove:
            .left
        case .rightInsole, .rightGlove:
            .right
        default:
            nil
        }
    }
}
