//
//  BSEnum.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Foundation

private let logger = getLogger(category: "BSEnum")

protocol BSEnum: RawRepresentable, CaseIterable, Sendable, Hashable where RawValue == UInt8 {
    var name: String { get }
}

extension BSEnum {
    var data: Data {
        rawValue.data
    }

    static func parse(_ data: Data, at offset: Data.Index = 0) -> Self? {
        let rawValue = data[offset]
        guard let value = Self(rawValue: rawValue) else {
            logger.error("invalid \(self) rawValue \(rawValue)")
            return nil
        }
        return value
    }
}

extension Array where Element: BSEnum {
    static func parse(_ data: Data) -> [Element]? {
        var array: [Element] = []
        for item in data {
            guard let value = Element.parse(data) else {
                return nil
            }
            array.append(value)
        }
        return array
    }

    var data: Data {
        self.reduce(into: Data()) { result, element in
            result.self.append(contentsOf: element.data)
        }
    }
}
