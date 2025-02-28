//
//  OptionSetUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation

private let logger = getLogger(category: "OptionSetUtils", disabled: true)

extension Array where Element: RawRepresentable, Element.RawValue == UInt8 {
    var rawValue: UInt8 {
        reduce(into: 0) { result, flag in
            result |= flag.rawValue
        }
    }

    var data: Data { rawValue.data }
}

extension OptionSet where Self: CaseIterable, Self.RawValue == UInt8 {
    static func parse(_ data: Data) -> [Self] {
        guard !data.isEmpty else {
            logger?.error("invalid data \(data)")
            return []
        }
        guard let rawValue: UInt8 = .parse(data) else {
            return []
        }
        return allCases
            .compactMap { flag in
                rawValue & flag.rawValue != 0 ? flag : nil
            }
    }
}

public extension Array where Element: CaseIterable {
    static var all: [Element] { Element.allCases as! [Element] }
}
