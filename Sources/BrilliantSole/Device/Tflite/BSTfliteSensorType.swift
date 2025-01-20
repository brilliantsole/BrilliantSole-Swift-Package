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
