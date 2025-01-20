//
//  BSActivity.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

public struct BSActivity: OptionSet, Sendable, CaseIterable {
    public static let allCases: [BSActivity] = [.still, .walking, .running, .bicycle, .vehicle, .tilting]

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let still = BSActivity(rawValue: 1 << 0)
    public static let walking = BSActivity(rawValue: 1 << 1)
    public static let running = BSActivity(rawValue: 1 << 2)
    public static let bicycle = BSActivity(rawValue: 1 << 3)
    public static let vehicle = BSActivity(rawValue: 1 << 4)
    public static let tilting = BSActivity(rawValue: 1 << 5)
}
