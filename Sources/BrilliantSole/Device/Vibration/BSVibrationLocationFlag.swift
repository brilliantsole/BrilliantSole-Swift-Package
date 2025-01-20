//
//  BSVibrationLocationFlag.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

public struct BSVibrationLocationFlag: OptionSet, Sendable, CaseIterable {
    public static let allCases: [BSVibrationLocationFlag] = [.front, .rear]

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let front = BSVibrationLocationFlag(rawValue: 1 << 0)
    public static let rear = BSVibrationLocationFlag(rawValue: 1 << 1)
}
