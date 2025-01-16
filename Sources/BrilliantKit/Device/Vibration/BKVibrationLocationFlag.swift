//
//  BKVibrationLocationFlag.swift
//  BrilliantKit
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

struct BKVibrationLocationFlag: OptionSet {
    let rawValue: UInt8

    static let front = BKVibrationLocationFlag(rawValue: 1 << 0)
    static let rear = BKVibrationLocationFlag(rawValue: 1 << 1)
}
