//
//  BSVibrationLocationFlag.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

public struct BSVibrationLocation: OptionSet, Sendable, CaseIterable {
    public static let allCases: [BSVibrationLocation] = [.front, .rear]

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let front = BSVibrationLocation(rawValue: 1 << 0)
    public static let rear = BSVibrationLocation(rawValue: 1 << 1)
}
