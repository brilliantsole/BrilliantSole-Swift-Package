//
//  BSVibrationLocationFlag.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

public struct BSVibrationLocationFlag: OptionSet, Sendable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let front = BSVibrationLocationFlag(rawValue: 1 << 0)
    public static let rear = BSVibrationLocationFlag(rawValue: 1 << 1)
}

extension Array where Element == BSVibrationLocationFlag {
    var rawValue: UInt8 {
        reduce(into: 0) { result, flag in
            result |= flag.rawValue
        }
    }
}
