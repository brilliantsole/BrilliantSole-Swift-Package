import Foundation

private let logger = getLogger(category: "ByteParsing")

// MARK: - Data to Object

extension Data {
    func parse<T>(at offset: Data.Index = .zero) -> T? {
        let size = MemoryLayout<T>.size
        guard offset + size <= count else {
            logger.error("Insufficient bytes: required \(size), available \(count - offset)")
            return nil
        }
        return subdata(in: offset ..< offset + size).withUnsafeBytes { $0.load(as: T.self) }
    }
}

// MARK: - Data to Number

extension FixedWidthInteger {
    static func parse(_ data: Data, at offset: Data.Index = .zero, littleEndian: Bool = true) -> Self? {
        guard let value: Self = data.parse(at: offset) else { return nil }
        return littleEndian ? value.littleEndian : value.bigEndian
    }
}

extension Float32 {
    static func parse(_ data: Data, at offset: Data.Index = .zero, littleEndian: Bool = true) -> Self? {
        guard var value: Self = data.parse(at: offset) else { return nil }
        if littleEndian != (UInt32(littleEndian: 1) == 1) {
            value = .init(bitPattern: value.bitPattern.byteSwapped)
        }
        return value
    }
}

extension Float64 {
    static func parse(_ data: Data, at offset: Data.Index = .zero, littleEndian: Bool = true) -> Self? {
        guard var value: Self = data.parse(at: offset) else { return nil }
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
        return withUnsafeBytes(of: &source) { Data($0) }
    }
}

extension FixedWidthInteger {
    func getData(littleEndian: Bool = true) -> Data {
        var source = littleEndian ? self.littleEndian : self.bigEndian
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
            logger.error("Invalid string range: offset \(offset), finalOffset \(finalOffset), data count \(count)")
            return ""
        }

        let nameData = subdata(in: offset ..< finalOffset)
        return String(data: nameData, encoding: .utf8) ?? ""
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
        return self.data(using: .utf8) ?? Data()
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

    static func parse(_ data: Data, at offset: Data.Index = .zero) -> Self? {
        guard offset < data.count else {
            logger.error("Invalid offset \(offset) for data size \(data.count)")
            return nil
        }
        return data[offset] == 1
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
