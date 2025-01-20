//
//  OptionSetUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation

extension Array where Element: RawRepresentable, Element.RawValue == UInt8 {
    var rawValue: UInt8 {
        reduce(into: 0) { result, flag in
            result |= flag.rawValue
        }
    }
}

extension OptionSet where Self: CaseIterable, Self.RawValue == UInt8 {
    static func parse(_ data: Data) -> [Self] {
        let rawValue = data[0]
        return allCases
            .compactMap { flag in
                rawValue & flag.rawValue != 0 ? flag : nil
            }
    }
}
