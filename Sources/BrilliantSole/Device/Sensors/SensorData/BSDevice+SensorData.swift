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

    var pressureDataPublisher: BSPressureDataPublisher {
        sensorDataManager.pressureSensorDataManager.pressureDataPublisher
    }

    var centerOfPressurePublisher: BSCenterOfPressurePublisher {
        sensorDataManager.pressureSensorDataManager.centerOfPressurePublisher
    }

    func resetPressure() {
        sensorDataManager.pressureSensorDataManager.reset()
    }

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

    var gyroscopePublisher: BSVector3DPublisher {
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

    var barometerPublisher: BSBarometerPublisher {
        sensorDataManager.barometerSensorDataManager.barometerPublisher
    }

    // MARK: - Vector publisher

    func getVectorPublisher(for sensorType: BSSensorType) -> BSVector3DPublisher? {
        return sensorDataManager.motionSensorDataManager.getVectorPublisher(for: sensorType)
    }

    // MARK: - Quaternion publisher

    func getQuaternionPublisher(for sensorType: BSSensorType) -> BSQuaternionPublisher? {
        return sensorDataManager.motionSensorDataManager.getQuaternionPublisher(for: sensorType)
    }
}

extension BSDevice: BSCenterOfPressureProvider {}
