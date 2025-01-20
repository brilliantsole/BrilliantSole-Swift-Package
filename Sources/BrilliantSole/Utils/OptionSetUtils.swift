//
//  OptionSetUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

extension Array where Element: RawRepresentable, Element.RawValue == UInt8 {
    var rawValue: UInt8 {
        reduce(into: 0) { result, flag in
            result |= flag.rawValue
        }
    }
}
