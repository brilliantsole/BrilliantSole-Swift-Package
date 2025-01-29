//
//  BSMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import Foundation

protocol BSMessageType {
    static func parse(_ data: Data, at offset: Data.Index) -> Self?
    static func parse(_ data: Data) -> Self?
}

extension BSMessageType {
    static func parse(_ data: Data) -> Self? { parse(data, at: .zero) }
}

extension FixedWidthInteger where Self: BSMessageType {
    static func parse(_ data: Data, at offset: Data.Index = .zero) -> Self? { .parse(data, at: offset, littleEndian: true) }
}

extension UInt8: BSMessageType {}
extension UInt16: BSMessageType {}
extension UInt32: BSMessageType {}
