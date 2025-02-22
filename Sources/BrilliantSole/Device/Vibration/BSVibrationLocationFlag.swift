//
//  BSVibrationLocationFlag.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import UkatonMacros

public struct BSVibrationLocationFlag: Identifiable, OptionSet, Sendable, CaseIterable {
    public var name: String {
        switch self {
        case .front:
            "front"
        case .rear:
            "rear"
        default:
            "unknown"
        }
    }

    public var id: UInt8 { rawValue }

    public static let allCases: [BSVibrationLocationFlag] = [.front, .rear]

    public let rawValue: UInt8
    var data: Data { rawValue.data }

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let front = BSVibrationLocationFlag(rawValue: 1 << 0)
    public static let rear = BSVibrationLocationFlag(rawValue: 1 << 1)
}
