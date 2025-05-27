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

public typealias BSStepCount = UInt32

public typealias BSVector3DData = (vector: BSVector3D, timestamp: BSTimestamp)
typealias BSVector3DSubject = PassthroughSubject<BSVector3DData, Never>
public typealias BSVector3DPublisher = AnyPublisher<BSVector3DData, Never>

public typealias BSRotation3DData = (rotation: BSRotation3D, timestamp: BSTimestamp)
typealias BSRotation3DSubject = PassthroughSubject<BSRotation3DData, Never>
public typealias BSRotation3DPublisher = AnyPublisher<BSRotation3DData, Never>

public typealias BSQuaternionData = (quaternion: BSQuaternion, timestamp: BSTimestamp)
typealias BSQuaternionSubject = PassthroughSubject<BSQuaternionData, Never>
public typealias BSQuaternionPublisher = AnyPublisher<BSQuaternionData, Never>

public typealias BSStepCountData = (stepCount: BSStepCount, timestamp: BSTimestamp)
typealias BSStepCountSubject = PassthroughSubject<BSStepCountData, Never>
public typealias BSStepCountPublisher = AnyPublisher<BSStepCountData, Never>

public typealias BSDeviceOrientationData = (deviceOrientation: BSDeviceOrientation, timestamp: BSTimestamp)
typealias BSDeviceOrientationSubject = PassthroughSubject<BSDeviceOrientationData, Never>
public typealias BSDeviceOrientationPublisher = AnyPublisher<BSDeviceOrientationData, Never>

public typealias BSActivityData = (activityFlags: BSActivityFlags, timestamp: BSTimestamp)
typealias BSActivitySubject = PassthroughSubject<BSActivityData, Never>
public typealias BSActivityPublisher = AnyPublisher<BSActivityData, Never>

public typealias BSVoidTimestampData = BSTimestamp
typealias BSVoidTimestampSubject = PassthroughSubject<BSVoidTimestampData, Never>
public typealias BSVoidTimestampPublisher = AnyPublisher<BSVoidTimestampData, Never>

@StaticLogger(disabled: true)
final class BSMotionSensorDataManager: BSBaseSensorDataManager {
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
        .tapDetection
    ] }

    override func parseSensorData(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        super.parseSensorData(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        switch sensorType {
        case .acceleration, .gravity, .linearAcceleration, .gyroscope, .magnetometer:
            parseVector(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        case .gameRotation, .rotation:
            parseQuaternion(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        case .orientation:
            parseRotation(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        case .activity:
            parseActivity(data: data, timestamp: timestamp)
        case .stepCount:
            parseStepCount(data: data, timestamp: timestamp)
        case .stepDetection:
            parseStepDetection(data: data, timestamp: timestamp)
        case .deviceOrientation:
            parseDeviceOrientation(data: data, timestamp: timestamp)
        case .tapDetection:
            parseTapDetection(data: data, timestamp: timestamp)
        default:
            break
        }
    }

    // MARK: - vector

    private let accelerationSubject: BSVector3DSubject = .init()
    var accelerationPublisher: BSVector3DPublisher {
        accelerationSubject.eraseToAnyPublisher()
    }

    private let gravitySubject: BSVector3DSubject = .init()
    var gravityPublisher: BSVector3DPublisher {
        gravitySubject.eraseToAnyPublisher()
    }

    private let linearAccelerationSubject: BSVector3DSubject = .init()
    var linearAccelerationPublisher: BSVector3DPublisher {
        linearAccelerationSubject.eraseToAnyPublisher()
    }

    private let gyroscopeSubject: BSVector3DSubject = .init()
    var gyroscopePublisher: BSVector3DPublisher {
        gyroscopeSubject.eraseToAnyPublisher()
    }

    private let magnetometerSubject: BSVector3DSubject = .init()
    var magnetometerPublisher: BSVector3DPublisher {
        magnetometerSubject.eraseToAnyPublisher()
    }

    private func getVectorSubject(for sensorType: BSSensorType) -> BSVector3DSubject? {
        guard sensorType.dataType == BSVector3D.self else {
            logger?.error("sensorType \(sensorType.name) does not have BSVector3D data type")
            return nil
        }

        return switch sensorType {
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

    func getVectorPublisher(for sensorType: BSSensorType) -> BSVector3DPublisher? {
        getVectorSubject(for: sensorType)?.eraseToAnyPublisher()
    }

    private func parseVector(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let vector = BSVector3D.parse(data, scalar: scalar) else { return }
        logger?.debug("parsed \(sensorType.name) vector: \(vector) (\(timestamp)ms")
        guard let vectorSubject = getVectorSubject(for: sensorType) else {
            fatalError("no vectorSubject defined for sensorType \(sensorType.name)")
        }
        vectorSubject.send((vector, timestamp))
    }

    // MARK: - quaternion

    private let gameRotationSubject: BSQuaternionSubject = .init()
    var gameRotationPublisher: BSQuaternionPublisher {
        gameRotationSubject.eraseToAnyPublisher()
    }

    private let rotationSubject: BSQuaternionSubject = .init()
    var rotationPublisher: BSQuaternionPublisher {
        rotationSubject.eraseToAnyPublisher()
    }

    private func getQuaternionSubject(for sensorType: BSSensorType) -> BSQuaternionSubject? {
        guard sensorType.dataType == BSQuaternion.self else {
            logger?.error("sensorType \(sensorType.name) does not have BSQuaternion data type")
            return nil
        }

        return switch sensorType {
        case .gameRotation:
            gameRotationSubject
        case .rotation:
            rotationSubject
        default:
            nil
        }
    }

    func getQuaternionPublisher(for sensorType: BSSensorType) -> BSQuaternionPublisher? {
        return getQuaternionSubject(for: sensorType)?.eraseToAnyPublisher()
    }

    private func parseQuaternion(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let quaternion = BSQuaternion.parse(data, scalar: scalar) else { return }
        logger?.debug("parsed \(sensorType.name) quaternion: \(String(describing: quaternion)) (\(timestamp)ms")
        guard let quaternionSubject = getQuaternionSubject(for: sensorType) else {
            fatalError("no quaternionSubject defined for sensorType \(sensorType.name)")
        }
        quaternionSubject.send((quaternion, timestamp))
    }

    // MARK: - rotation

    private let orientationSubject: BSRotation3DSubject = .init()
    var orientationPublisher: BSRotation3DPublisher {
        orientationSubject.eraseToAnyPublisher()
    }

//    private let gyroscopeSubject: BSRotation3DSubject = .init()
//    var gyroscopePublisher: BSRotation3DPublisher {
//        gyroscopeSubject.eraseToAnyPublisher()
//    }

    private func getRotationSubject(for sensorType: BSSensorType) -> BSRotation3DSubject? {
        guard sensorType.dataType == BSRotation3D.self else {
            logger?.error("sensorType \(sensorType.name) does not have BSRotation3D data type")
            return nil
        }

        return switch sensorType {
        case .orientation:
            orientationSubject
//        case .gyroscope:
//            gyroscopeSubject
        default:
            nil
        }
    }

    func parseRotation(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let rotation = BSRotation3D.parse(data, scalar: scalar, sensorType: sensorType) else { return }
        logger?.debug("parsed rotation: \(rotation) (\(timestamp)ms")
        guard let rotationSubject = getRotationSubject(for: sensorType) else {
            fatalError("no rotationSubject defined for sensorType \(sensorType.name)")
        }
        rotationSubject.send((rotation, timestamp))
    }

    // MARK: - activity

    private let activitySubject = BSActivitySubject()
    var activityPublisher: BSActivityPublisher {
        activitySubject.eraseToAnyPublisher()
    }

    private func parseActivity(data: Data, timestamp: BSTimestamp) {
        let activity = BSActivityFlag.parse(data)
        logger?.debug("parsed activity: \(activity) (\(timestamp)ms)")
        activitySubject.send((activity, timestamp))
    }

    // MARK: - stepDetection

    private let stepDetectionSubject = BSVoidTimestampSubject()
    var stepDetectionPublisher: BSVoidTimestampPublisher {
        stepDetectionSubject.eraseToAnyPublisher()
    }

    private func parseStepDetection(data: Data, timestamp: BSTimestamp) {
        logger?.debug("step detected (\(timestamp)ms)")
        stepDetectionSubject.send(timestamp)
    }

    // MARK: - stepCount

    private let stepCountSubject = BSStepCountSubject()
    var stepCountPublisher: BSStepCountPublisher {
        stepCountSubject.eraseToAnyPublisher()
    }

    private func parseStepCount(data: Data, timestamp: BSTimestamp) {
        guard let stepCount = BSStepCount.parse(data, littleEndian: true) else { return }
        logger?.debug("stepCount: \(stepCount) (\(timestamp)ms)")
        stepCountSubject.send((stepCount, timestamp))
    }

    // MARK: - deviceOrientation

    private let deviceOrientationSubject = BSDeviceOrientationSubject()
    var deviceOrientationPublisher: BSDeviceOrientationPublisher {
        deviceOrientationSubject.eraseToAnyPublisher()
    }

    private func parseDeviceOrientation(data: Data, timestamp: BSTimestamp) {
        guard let deviceOrientation = BSDeviceOrientation.parse(data) else {
            return
        }
        logger?.debug("deviceOrientation: \(deviceOrientation.name) (\(timestamp)ms")
        deviceOrientationSubject.send((deviceOrientation, timestamp))
    }

    // MARK: - tapDetection

    private let tapDetectionSubject = BSVoidTimestampSubject()
    var tapDetectionPublisher: BSVoidTimestampPublisher {
        tapDetectionSubject.eraseToAnyPublisher()
    }

    private func parseTapDetection(data: Data, timestamp: BSTimestamp) {
        logger?.debug("tap detected (\(timestamp)ms)")
        tapDetectionSubject.send(timestamp)
    }
}
