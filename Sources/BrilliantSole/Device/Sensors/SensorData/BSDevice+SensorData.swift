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

    private func setupPressureData() {
        sensorDataManager.pressureSensorDataManager.pressureDataPublisher.sink { pressureData, timestamp in
            self.pressureDataSubject.send((pressureData, timestamp))
        }.store(in: &managerCancellables)
    }

    // MARK: - motion

    private func setupMotionData() {
        sensorDataManager.motionSensorDataManager.accelerationPublisher.sink { acceleration, timestamp in
            self.accelerationSubject.send((acceleration, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.linearAccelerationPublisher.sink { acceleration, timestamp in
            self.linearAccelerationSubject.send((acceleration, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.gravityPublisher.sink { gravity, timestamp in
            self.gravitySubject.send((gravity, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.gyroscopePublisher.sink { gyroscope, timestamp in
            self.gyroscopeSubject.send((gyroscope, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.magnetometerPublisher.sink { magnetometer, timestamp in
            self.magnetometerSubject.send((magnetometer, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.gameRotationPublisher.sink { rotation, timestamp in
            self.gameRotationSubject.send((rotation, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.rotationPublisher.sink { rotation, timestamp in
            self.rotationSubject.send((rotation, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.orientationPublisher.sink { orientation, timestamp in
            self.orientationSubject.send((orientation, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.stepCountPublisher.sink { stepCount, timestamp in
            self.stepCountSubject.send((stepCount, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.stepDetectionPublisher.sink { timestamp in
            self.stepDetectionSubject.send(timestamp)
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.activityPublisher.sink { activity, timestamp in
            self.activitySubject.send((activity, timestamp))
        }.store(in: &managerCancellables)

        sensorDataManager.motionSensorDataManager.deviceOrientationPublisher.sink { orientation, timestamp in
            self.deviceOrientationSubject.send((orientation, timestamp))
        }.store(in: &managerCancellables)
    }

    // MARK: - barometer

    private func setupBarometerData() {
        sensorDataManager.barometerSensorDataManager.barometerPublisher.sink { barometerData, timestamp in
            self.barometerSubject.send((barometerData, timestamp))
        }.store(in: &managerCancellables)
    }
}
