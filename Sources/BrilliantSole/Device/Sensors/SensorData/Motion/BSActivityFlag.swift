//
//  BSActivity.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

public struct BSActivityFlag: OptionSet, Sendable, CaseIterable {
    public static let allCases: [BSActivityFlag] = [.still, .walking, .running, .bicycle, .vehicle, .tilting]

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let still = BSActivityFlag(rawValue: 1 << 0)
    public static let walking = BSActivityFlag(rawValue: 1 << 1)
    public static let running = BSActivityFlag(rawValue: 1 << 2)
    public static let bicycle = BSActivityFlag(rawValue: 1 << 3)
    public static let vehicle = BSActivityFlag(rawValue: 1 << 4)
    public static let tilting = BSActivityFlag(rawValue: 1 << 5)
}

public typealias BSActivityFlags = [BSActivityFlag]
