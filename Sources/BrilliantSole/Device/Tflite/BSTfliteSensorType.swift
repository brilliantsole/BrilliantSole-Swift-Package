//
//  BSTfliteSensorType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

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
}
