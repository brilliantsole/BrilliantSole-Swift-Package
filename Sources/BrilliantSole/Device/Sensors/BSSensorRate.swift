//
//  BSSensorRate.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

private let logger = getLogger(category: "BSSensorRate")

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

extension BSSensorRate {
    static func parse(_ data: Data, littleEndian: Bool = true) -> Self? {
        let rawValue: Self.RawValue = .parse(data, littleEndian: littleEndian)
        guard let value = Self(rawValue: rawValue) else {
            logger.error("invalid \(self) rawValue \(rawValue)")
            return nil
        }
        return value
    }

    func getData(littleEndian: Bool = true) -> Data {
        rawValue.getData(littleEndian: littleEndian)
    }
}
