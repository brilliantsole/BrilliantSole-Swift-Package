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
    private let accelerationSubject: BSVector3DSubject = .init()
    var accelerationPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        accelerationSubject.eraseToAnyPublisher()
    }

    private let gravitySubject: BSVector3DSubject = .init()
    var gravityPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        gravitySubject.eraseToAnyPublisher()
    }

    private let linearAccelerationSubject: BSVector3DSubject = .init()
    var linearAccelerationPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        linearAccelerationSubject.eraseToAnyPublisher()
    }

    private let gyroscopeSubject: BSVector3DSubject = .init()
    var gyroscopePublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        gyroscopeSubject.eraseToAnyPublisher()
    }

    private let magnetometerSubject: BSVector3DSubject = .init()
    var magnetometerPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        magnetometerSubject.eraseToAnyPublisher()
    }

    private func getVectorSubject(for sensorType: BSSensorType) -> BSVector3DSubject? {
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

    private func parseVector(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let vector = BSVector3D.parse(data, scalar: scalar) else { return }
        logger?.debug("parsed \(sensorType.name) vector: \(vector) (\(timestamp)ms")
        guard let vectorSubject = getVectorSubject(for: sensorType) else {
            fatalError("no vectorSubject defined for sensorType \(sensorType.name)")
        }
        vectorSubject.send((vector, timestamp))
    }

    // MARK: - quaternion

    typealias BSQuaternionSubject = PassthroughSubject<(BSQuaternion, BSTimestamp), Never>
    private let gameRotationSubject: BSQuaternionSubject = .init()
    var gameRotationPublisher: AnyPublisher<(BSQuaternion, BSTimestamp), Never> {
        gameRotationSubject.eraseToAnyPublisher()
    }

    private let rotationSubject: BSQuaternionSubject = .init()
    var rotationPublisher: AnyPublisher<(BSQuaternion, BSTimestamp), Never> {
        rotationSubject.eraseToAnyPublisher()
    }

    private func getQuaternionSubject(for sensorType: BSSensorType) -> BSQuaternionSubject? {
        switch sensorType {
        case .gameRotation:
            gameRotationSubject
        case .rotation:
            rotationSubject
        default:
            nil
        }
    }

    private func parseQuaternion(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let quaternion = BSQuaternion.parse(data, scalar: scalar) else { return }
        logger?.debug("parsed \(sensorType.name) quaternion: \(String(describing: quaternion)) (\(timestamp)ms")
        guard let quaternionSubject = getQuaternionSubject(for: sensorType) else {
            fatalError("no quaternionSubject defined for sensorType \(sensorType.name)")
        }
        quaternionSubject.send((quaternion, timestamp))
    }

    // MARK: - orientation

    private let orientationSubject = PassthroughSubject<(BSRotation3D, BSTimestamp), Never>()
    var orientationPublisher: AnyPublisher<(BSRotation3D, BSTimestamp), Never> {
        orientationSubject.eraseToAnyPublisher()
    }

    func parseOrientation(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let orientation = BSRotation3D.parse(data, scalar: scalar) else { return }
        logger?.debug("parsed orientation: \(orientation) (\(timestamp)ms")
        orientationSubject.send((orientation, timestamp))
    }

    // MARK: - activity

    private let activitySubject = PassthroughSubject<(BSActivityFlags, BSTimestamp), Never>()
    var activityPublisher: AnyPublisher<(BSActivityFlags, BSTimestamp), Never> {
        activitySubject.eraseToAnyPublisher()
    }

    private func parseActivity(data: Data, timestamp: BSTimestamp) {
        let activity = BSActivityFlag.parse(data)
        logger?.debug("parsed activity: \(activity) (\(timestamp)ms)")
        activitySubject.send((activity, timestamp))
    }

    // MARK: - stepDetection

    private let stepDetectionSubject = PassthroughSubject<BSTimestamp, Never>()
    var stepDetectionPublisher: AnyPublisher<BSTimestamp, Never> {
        stepDetectionSubject.eraseToAnyPublisher()
    }

    private func parseStepDetection(data: Data, timestamp: BSTimestamp) {
        logger?.debug("step detected (\(timestamp)ms)")
        stepDetectionSubject.send(timestamp)
    }

    // MARK: - stepCount

    private let stepCountSubject = PassthroughSubject<(BSStepCount, BSTimestamp), Never>()
    var stepCountPublisher: AnyPublisher<(BSStepCount, BSTimestamp), Never> {
        stepCountSubject.eraseToAnyPublisher()
    }

    private func parseStepCount(data: Data, timestamp: BSTimestamp) {
        guard let stepCount = BSStepCount.parse(data, littleEndian: false) else { return }
        logger?.debug("stepCount: \(stepCount) (\(timestamp)ms)")
        stepCountSubject.send((stepCount, timestamp))
    }

    // MARK: - deviceOrientation

    private let deviceOrientationSubject = PassthroughSubject<(BSDeviceOrientation, BSTimestamp), Never>()
    var deviceOrientationPublisher: AnyPublisher<(BSDeviceOrientation, BSTimestamp), Never> {
        deviceOrientationSubject.eraseToAnyPublisher()
    }

    private func parseDeviceOrientation(data: Data, timestamp: BSTimestamp) {
        guard let deviceOrientation = BSDeviceOrientation.parse(data) else {
            return
        }
        logger?.debug("deviceOrientation: \(deviceOrientation.name) (\(timestamp)ms")
        deviceOrientationSubject.send((deviceOrientation, timestamp))
    }
}
