//
//  BSMotionSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Combine
import Foundation
import OSLog
import UkatonMacros

@StaticLogger
class BSMotionSensorDataManager: BSBaseSensorDataManager {
    override class var sensorTypes: Set<BSSensorType> { [
        .acceleration,
        .gravity,
        .linearAcceleration,
        .gyroscope,
        .magnetometer,
        .gameRotation,
        .rotation,

        .orientation,
        .activity,
        .stepCount,
        .stepDetection,
        .deviceOrientation,
    ] }

    override func parseSensorData(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        super.parseSensorData(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        switch sensorType {
        case .acceleration, .gravity, .linearAcceleration, .gyroscope, .magnetometer:
            parseVector(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        case .gameRotation, .rotation:
            parseQuaternion(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        case .orientation:
            parseOrientation(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        case .activity:
            parseActivity(data: data, timestamp: timestamp)
        case .stepCount:
            parseStepCount(data: data, timestamp: timestamp)
        case .stepDetection:
            parseStepDetection(data: data, timestamp: timestamp)
        case .deviceOrientation:
            parseDeviceOrientation(data: data, timestamp: timestamp)
        default:
            break
        }
    }

    // MARK: - vector

    let accelerationSubject = PassthroughSubject<(BSVector3D, BSTimestamp), Never>()
    let gravitySubject = PassthroughSubject<(BSVector3D, BSTimestamp), Never>()
    let linearAccelerationSubject = PassthroughSubject<(BSVector3D, BSTimestamp), Never>()
    let gyroscopeSubject = PassthroughSubject<(BSVector3D, BSTimestamp), Never>()
    let magnetometerSubject = PassthroughSubject<(BSVector3D, BSTimestamp), Never>()

    func parseVector(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        // FILL
    }

    // MARK: - quaternion

    let gameRotationSubject = PassthroughSubject<(BSQuaternion, BSTimestamp), Never>()
    let rotationSubject = PassthroughSubject<(BSQuaternion, BSTimestamp), Never>()

    func parseQuaternion(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        // FILL
    }

    // MARK: - orientation

    let orientationSubject = PassthroughSubject<(BSRotation3D, BSTimestamp), Never>()

    func parseOrientation(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        // FILL
    }

    // MARK: - activity

    let activitySubject = PassthroughSubject<([BSActivityFlag], BSTimestamp), Never>()

    func parseActivity(data: Data, timestamp: BSTimestamp) {
        // FILL
    }

    // MARK: - stepDetection

    let stepDetectionSubject = PassthroughSubject<BSTimestamp, Never>()

    func parseStepDetection(data: Data, timestamp: BSTimestamp) {
        // FILL
    }

    // MARK: - stepCount

    let stepCountSubject = PassthroughSubject<(UInt32, BSTimestamp), Never>()

    func parseStepCount(data: Data, timestamp: BSTimestamp) {
        // FILL
    }

    // MARK: - deviceOrientation

    let deviceOrientationSubject = PassthroughSubject<(BSDeviceOrientation, BSTimestamp), Never>()
    func parseDeviceOrientation(data: Data, timestamp: BSTimestamp) {
        // FILL
    }
}
