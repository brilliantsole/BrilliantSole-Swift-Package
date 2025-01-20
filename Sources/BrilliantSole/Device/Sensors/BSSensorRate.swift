//
//  BSSensorRate.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName
public enum BSSensorRate: UInt16, CaseIterable, Sendable {
    case _0ms = 0
    case _5ms = 5
    case _10ms = 10
    case _20ms = 20
    case _40ms = 40
    case _80ms = 80
    case _100ms = 100
}
