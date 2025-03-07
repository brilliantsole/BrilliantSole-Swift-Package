//
//  BSSensorRate.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

private let logger = getLogger(category: "BSSensorRate", disabled: true)

public enum BSSensorRate: UInt16, CaseIterable, Sendable, Identifiable {
    public var id: Self { self }

    case _0ms = 0
    case _5ms = 5
    case _10ms = 10
    case _20ms = 20
    case _40ms = 40
    case _80ms = 80
    case _100ms = 100

    public var name: String {
        switch self {
        case ._0ms:
            "0ms"
        case ._5ms:
            "5ms"
        case ._10ms:
            "10ms"
        case ._20ms:
            "20ms"
        case ._40ms:
            "40ms"
        case ._80ms:
            "80ms"
        case ._100ms:
            "100ms"
        }
    }
}

extension BSSensorRate {
    static func parse(_ data: Data, at offset: Data.Index = .zero, littleEndian: Bool = true) -> Self? {
        guard let rawValue = RawValue.parse(data, at: offset, littleEndian: littleEndian) else { return nil }
        guard let value = Self(rawValue: rawValue) else {
            logger?.error("invalid \(self) rawValue \(rawValue)")
            return nil
        }
        return value
    }

    func getData(littleEndian: Bool = true) -> Data {
        rawValue.getData(littleEndian: littleEndian)
    }
}
