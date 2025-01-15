import Foundation

// MARK: - for initializing BKSensorDataConfigurations

extension Dictionary where Key: CaseIterable & RawRepresentable, Key.RawValue: Numeric, Value: Numeric {
    static var zero: Self {
        var zero: Self = .init()
        Key.allCases.forEach { zero[$0] = .zero }
        return zero
    }

    var data: Data {
        var data: Data = .init()
        forEach { key, value in
            data.append(key.rawValue.data)
            data.append(value.data)
        }
        return data
    }
}

// MARK: - for checking BKSensorDataConfigurations is zero

extension Dictionary where Value: BinaryInteger {
    var isZero: Bool {
        !self.contains(where: { $1 > 0 })
    }
}

// MARK: - for BKMotionCalibration

extension Dictionary where Key: CaseIterable & RawRepresentable, Key.RawValue: Numeric, Value: RawRepresentable, Value.RawValue: Numeric {
    static var zero: Self {
        var zero: Self = .init()
        Key.allCases.forEach { zero[$0] = .init(rawValue: .zero) }
        return zero
    }
}

// MARK: - for json

public protocol Nameable {
    var name: String { get }
}
