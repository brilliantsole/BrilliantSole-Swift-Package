//
//  ByteParsing.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation

// MARK: - Data to Object

extension Data {
    func parse<T>(at offset: Data.Index = .zero) -> T {
        let size = MemoryLayout<T>.size
        let value = subdata(in: Data.Index(offset) ..< self.index(Data.Index(offset), offsetBy: size))
            .withUnsafeBytes { $0.load(as: T.self) }
        return value
    }
}

// MARK: - Data to Number

extension FixedWidthInteger {
    static func parse(_ data: Data, at offset: Data.Index = .zero, littleEndian: Bool = true) -> Self {
        let value: Self = data.parse(at: offset)
        return littleEndian ? value.littleEndian : value.bigEndian
    }
}

extension Float32 {
    static func parse(_ data: Data, at offset: Data.Index = .zero, littleEndian: Bool = true) -> Self {
        var value: Self = data.parse(at: offset)

        if littleEndian != (UInt32(littleEndian: 1) == 1) {
            value = .init(bitPattern: value.bitPattern.byteSwapped)
        }
        return value
    }
}

extension Float64 {
    static func parse(_ data: Data, at offset: Data.Index = .zero, littleEndian: Bool = true) -> Self {
        var value: Self = data.parse(at: offset)

        if littleEndian != (UInt64(littleEndian: 1) == 1) {
            value = .init(bitPattern: value.bitPattern.byteSwapped)
        }
        return value
    }
}

// MARK: - Number to Data

extension Numeric {
    var data: Data {
        var source = self
        // return Data(bytes: &source, count: MemoryLayout<Self>.size)
        return withUnsafeBytes(of: &source) { Data($0) }
    }
}

extension FixedWidthInteger {
    func getData(littleEndian: Bool = true) -> Data {
        var source = littleEndian ? self.littleEndian : self.bigEndian
        // return Data(bytes: &source, count: MemoryLayout<Self>.size)
        return withUnsafeBytes(of: &source) { Data($0) }
    }
}

extension BinaryFloatingPoint {
    func getData(littleEndian: Bool = true) -> Data {
        if let value = self as? Float {
            var bitPattern = littleEndian ? value.bitPattern.littleEndian : value.bitPattern.bigEndian
            return withUnsafeBytes(of: &bitPattern) { Data($0) }
        } else if let value = self as? Double {
            var bitPattern = littleEndian ? value.bitPattern.littleEndian : value.bitPattern.bigEndian
            return withUnsafeBytes(of: &bitPattern) { Data($0) }
        } else {
            fatalError("Unsupported type: \(type(of: self))")
        }
    }
}

// MARK: - Data to String

extension Data {
    func parseString(offset: Data.Index = .zero, until finalOffset: Data.Index) -> String {
        guard offset < finalOffset, finalOffset <= count else {
            return ""
        }

        let nameDataRange = Data.Index(offset) ..< Data.Index(finalOffset)
        let nameData = subdata(in: nameDataRange)
        guard let newName = String(data: nameData, encoding: .utf8) else {
            return ""
        }
        return newName
    }
}

extension String {
    static func parse(_ data: Data, at offset: Data.Index = .zero) -> Self {
        data.parseString(offset: offset, until: data.count)
    }
}

// MARK: - String to Data

extension String {
    var data: Data {
        return self.data(using: .utf8)!
    }
}

// MARK: - Bool to Data

extension Bool {
    var number: UInt8 {
        self ? 1 : 0
    }

    var data: Data {
        return .init([self.number])
    }

    static func parse(_ data: Data, at offset: Data.Index = .zero) -> Self {
        data[offset] == 1
    }
}

// MARK: - Data to [UInt8]

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

// MARK: - [UInt8] to Data

extension Array where Element == UInt8 {
    var data: Data {
        return .init(self)
    }
}
