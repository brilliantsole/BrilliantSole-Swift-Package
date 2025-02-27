//
//  BSInsoleSide.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSInsoleSide: CaseIterable, Sendable {
    case left
    case right

    var otherSide: BSInsoleSide {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}
