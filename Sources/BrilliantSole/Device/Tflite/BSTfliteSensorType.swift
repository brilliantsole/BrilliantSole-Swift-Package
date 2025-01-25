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

    init?(_ sensorType: BSSensorType) {
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

    static func parse(_ data: Data, at offset: Data.Index = 0) -> Self? {
        guard let sensorType = BSSensorType.parse(data, at: offset), sensorType.isTfliteSensorType() else {
            return nil
        }
        return .init(sensorType)
    }
}

typealias BSTfliteSensorTypes = Set<BSTfliteSensorType>

extension Set where Element == BSTfliteSensorType {
    static func parse(_ data: Data) -> Set<Element>? {
        var set: Set<Element> = []
        for item in data {
            guard let value = Element.parse(data) else {
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
