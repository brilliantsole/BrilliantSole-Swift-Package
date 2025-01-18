//
//  BSVibrationLocationFlag.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

struct BSVibrationLocationFlag: OptionSet {
    let rawValue: UInt8

    static let front = BSVibrationLocationFlag(rawValue: 1 << 0)
    static let rear = BSVibrationLocationFlag(rawValue: 1 << 1)
}
