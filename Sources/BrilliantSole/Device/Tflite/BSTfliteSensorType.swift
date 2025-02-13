//
//  BSTfliteSensorType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation

extension BSSensorType {
    static let tfliteSensorTypes: [BSSensorType] = [.pressure, .linearAcceleration, .gyroscope, .magnetometer]

    func isTfliteSensorType() -> Bool {
        return Self.tfliteSensorTypes.contains(self)
    }
}

public enum BSTfliteSensorType: CaseIterable {
    case pressure
    case linearAcceleration
    case gyroscope
    case magnetometer

    var sensorType: BSSensorType {
        switch self {
        case .pressure:
            return .pressure
        case .linearAcceleration:
            return .linearAcceleration
        case .gyroscope:
            return .gyroscope
        case .magnetometer:
            return .magnetometer
        }
    }

    init?(sensorType: BSSensorType) {
        switch sensorType {
        case .pressure:
            self = .pressure
        case .linearAcceleration:
            self = .linearAcceleration
        case .gyroscope:
            self = .gyroscope
        case .magnetometer:
            self = .magnetometer
        default:
            return nil
        }
    }

    init?(rawValue: BSSensorType.RawValue) {
        guard let sensorType = BSSensorType(rawValue: rawValue) else {
            return nil
        }
        guard let tfliteSensorType = Self(sensorType: sensorType) else {
            return nil
        }
        self = tfliteSensorType
    }

    static func parse(_ data: Data, at offset: Data.Index = .zero) -> Self? {
        guard let sensorType = BSSensorType.parse(data, at: offset), sensorType.isTfliteSensorType() else {
            return nil
        }
        return .init(sensorType: sensorType)
    }
}

public typealias BSTfliteSensorTypes = Set<BSTfliteSensorType>

extension Collection where Element == BSTfliteSensorType {
    static func parse(_ data: Data) -> BSTfliteSensorTypes? {
        var set: BSTfliteSensorTypes = []
        for rawValue in data {
            guard let value = Element(rawValue: rawValue) else {
                return nil
            }
            set.insert(value)
        }
        return set
    }

    var sensorTypes: [BSSensorType] { map { $0.sensorType }}
    var data: Data {
        sensorTypes.data
    }
}
