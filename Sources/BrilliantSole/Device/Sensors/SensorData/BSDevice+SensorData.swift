//
//  BSDevice+SensorData.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    internal func setupSensorData() {
        setupPressureData()
        setupMotionData()
        setupBarometerData()
    }

    // MARK: - pressure

    private func setupPressureData() {}

    var pressureDataPublisher: AnyPublisher<(BSPressureData, BSTimestamp), Never> { sensorDataManager.pressureSensorDataManager.pressureDataPublisher }

    // MARK: - motion

    private func setupMotionData() {}

    var accelerationPublisher: BSVector3DPublisher {
        sensorDataManager.motionSensorDataManager.accelerationPublisher
    }

    var linearAccelerationPublisher: BSVector3DPublisher {
        sensorDataManager.motionSensorDataManager.linearAccelerationPublisher
    }

    var gravityPublisher: BSVector3DPublisher {
        sensorDataManager.motionSensorDataManager.gravityPublisher
    }

    var gyroscopePublisher: BSRotation3DPublisher {
        sensorDataManager.motionSensorDataManager.gyroscopePublisher
    }

    var magnetometerPublisher: BSVector3DPublisher {
        sensorDataManager.motionSensorDataManager.magnetometerPublisher
    }

    var gameRotationPublisher: BSQuaternionPublisher {
        sensorDataManager.motionSensorDataManager.gameRotationPublisher
    }

    var rotationPublisher: BSQuaternionPublisher {
        sensorDataManager.motionSensorDataManager.rotationPublisher
    }

    var orientationPublisher: BSRotation3DPublisher {
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

    private func setupBarometerData() {}

    var barometerPublisher: AnyPublisher<(BSBarometer, BSTimestamp), Never> {
        sensorDataManager.barometerSensorDataManager.barometerPublisher
    }
}
