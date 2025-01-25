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

    typealias BSVector3DSubject = PassthroughSubject<(BSVector3D, BSTimestamp), Never>
    let accelerationSubject: BSVector3DSubject = .init()
    let gravitySubject: BSVector3DSubject = .init()
    let linearAccelerationSubject: BSVector3DSubject = .init()
    let gyroscopeSubject: BSVector3DSubject = .init()
    let magnetometerSubject: BSVector3DSubject = .init()
    func getVectorSubject(for sensorType: BSSensorType) -> BSVector3DSubject? {
        switch sensorType {
        case .acceleration:
            accelerationSubject
        case .gravity:
            gravitySubject
        case .linearAcceleration:
            linearAccelerationSubject
        case .gyroscope:
            gyroscopeSubject
        case .magnetometer:
            magnetometerSubject
        default:
            nil
        }
    }

    func parseVector(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        let vector: BSVector3D = .parse(data, scalar: scalar)
        logger.debug("parsed \(sensorType.name) vector: \(vector) (\(timestamp)ms")
        guard let vectorSubject = getVectorSubject(for: sensorType) else {
            fatalError("no vectorSubject defined for sensorType \(sensorType.name)")
        }
        vectorSubject.send((vector, timestamp))
    }

    // MARK: - quaternion

    typealias BSQuaternionSubject = PassthroughSubject<(BSQuaternion, BSTimestamp), Never>
    let gameRotationSubject: BSQuaternionSubject = .init()
    let rotationSubject: BSQuaternionSubject = .init()
    func getQuaternionSubject(for sensorType: BSSensorType) -> BSQuaternionSubject? {
        switch sensorType {
        case .gameRotation:
            gameRotationSubject
        case .rotation:
            rotationSubject
        default:
            nil
        }
    }

    func parseQuaternion(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        let quaternion: BSQuaternion = .parse(data, scalar: scalar)
        logger.debug("parsed \(sensorType.name) quaternion: \(String(describing: quaternion)) (\(timestamp)ms")
        guard let quaternionSubject = getQuaternionSubject(for: sensorType) else {
            fatalError("no quaternionSubject defined for sensorType \(sensorType.name)")
        }
        quaternionSubject.send((quaternion, timestamp))
    }

    // MARK: - orientation

    let orientationSubject = PassthroughSubject<(BSRotation3D, BSTimestamp), Never>()

    func parseOrientation(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        let orientation: BSRotation3D = .parse(data, scalar: scalar)
        logger.debug("parsed orientation: \(orientation) (\(timestamp)ms")
        orientationSubject.send((orientation, timestamp))
    }

    // MARK: - activity

    let activitySubject = PassthroughSubject<([BSActivityFlag], BSTimestamp), Never>()

    func parseActivity(data: Data, timestamp: BSTimestamp) {
        let activity = BSActivityFlag.parse(data)
        logger.debug("parsed activity: \(activity) (\(timestamp)ms)")
        activitySubject.send((activity, timestamp))
    }

    // MARK: - stepDetection

    let stepDetectionSubject = PassthroughSubject<BSTimestamp, Never>()

    func parseStepDetection(data: Data, timestamp: BSTimestamp) {
        logger.debug("step detected (\(timestamp)ms)")
        stepDetectionSubject.send(timestamp)
    }

    // MARK: - stepCount

    let stepCountSubject = PassthroughSubject<(UInt32, BSTimestamp), Never>()

    func parseStepCount(data: Data, timestamp: BSTimestamp) {
        let stepCount: UInt32 = .parse(data, littleEndian: false)
        logger.debug("stepCount: \(stepCount) (\(timestamp)ms)")
        stepCountSubject.send((stepCount, timestamp))
    }

    // MARK: - deviceOrientation

    let deviceOrientationSubject = PassthroughSubject<(BSDeviceOrientation, BSTimestamp), Never>()
    func parseDeviceOrientation(data: Data, timestamp: BSTimestamp) {
        let rawDeviceOrientation = data[0]
        guard let deviceOrientation: BSDeviceOrientation = .init(rawValue: rawDeviceOrientation) else {
            fatalError("invalid rawDeviceOrientation: \(rawDeviceOrientation)")
        }
        logger.debug("deviceOrientation: \(deviceOrientation.name) (\(timestamp)ms")
        deviceOrientationSubject.send((deviceOrientation, timestamp))
    }
}
