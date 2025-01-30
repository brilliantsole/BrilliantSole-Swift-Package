//
//  BSDevice+SensorData.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    // MARK: - pressure

    var pressureDataPublisher: AnyPublisher<(BSPressureData, BSTimestamp), Never> {
        sensorDataManager.pressureSensorDataManager.pressureDataPublisher
    }

    // MARK: - motion

    var accelerationPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.accelerationPublisher
    }

    var linearAccelerationPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.linearAccelerationPublisher
    }

    var gravityPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.gravityPublisher
    }

    var gyroscopePublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.gyroscopePublisher
    }

    var magnetometerPublisher: AnyPublisher<(BSVector3D, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.magnetometerPublisher
    }

    var gameRotationPublisher: AnyPublisher<(BSQuaternion, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.gameRotationPublisher
    }

    var rotationPublisher: AnyPublisher<(BSQuaternion, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.rotationPublisher
    }

    var orientationPublisher: AnyPublisher<(BSRotation3D, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.orientationPublisher
    }

    var stepCountPublisher: AnyPublisher<(BSStepCount, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.stepCountPublisher
    }

    var stepDetectionPublisher: AnyPublisher<BSTimestamp, Never> {
        sensorDataManager.motionSensorDataManager.stepDetectionPublisher
    }

    var activityPublisher: AnyPublisher<(BSActivityFlags, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.activityPublisher
    }

    var deviceOrientationPublisher: AnyPublisher<(BSDeviceOrientation, BSTimestamp), Never> {
        sensorDataManager.motionSensorDataManager.deviceOrientationPublisher
    }

    // MARK: - barometer

    var barometerPublisher: AnyPublisher<(BSBarometer, BSTimestamp), Never> {
        sensorDataManager.barometerSensorDataManager.barometerPublisher
    }
}
