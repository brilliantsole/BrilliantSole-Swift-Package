//
//  BSDevicePair+SensorData.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

public extension BSDevicePair {
    func addDeviceSensorDataListeners(device: BSDevice) {
        addDevicePressureSensorDataListeners(device: device)
        addDeviceMotionSensorDataListeners(device: device)
        addDeviceBarometerSensorDataListeners(device: device)
    }

    // MARK: - pressure

    private func addDevicePressureSensorDataListeners(device: BSDevice) {
        device.pressureDataPublisher.sink { [self] pressureData, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            devicePressureDataSubject.send((insoleSide, device, pressureData, timestamp))
            sensorDataManager.pressureSensorDataManager.onDevicePressureData(insoleSide: insoleSide, pressureData: pressureData, timestamp: timestamp)
        }.store(in: &deviceCancellables[device]!)
    }

    // MARK: - motion

    private func addDeviceMotionSensorDataListeners(device: BSDevice) {
        device.accelerationPublisher.sink { [self] acceleration, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceAccelerationSubject.send((insoleSide, device, acceleration, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gravityPublisher.sink { [self] gravity, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceGravitySubject.send((insoleSide, device, gravity, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.linearAccelerationPublisher.sink { [self] linearAcceleration, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceLinearAccelerationSubject.send((insoleSide, device, linearAcceleration, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gyroscopePublisher.sink { [self] gyroscope, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceGyroscopeSubject.send((insoleSide, device, gyroscope, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.magnetometerPublisher.sink { [self] magnetometer, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceMagnetometerSubject.send((insoleSide, device, magnetometer, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gameRotationPublisher.sink { [self] gameRotation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceGameRotationSubject.send((insoleSide, device, gameRotation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.rotationPublisher.sink { [self] rotation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceRotationSubject.send((insoleSide, device, rotation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.orientationPublisher.sink { [self] orientation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceOrientationSubject.send((insoleSide, device, orientation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.stepCountPublisher.sink { [self] stepCount, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceStepCountSubject.send((insoleSide, device, stepCount, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.stepDetectionPublisher.sink { [self] timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceStepDetectionSubject.send((insoleSide, device, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.activityPublisher.sink { [self] activity, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceActivitySubject.send((insoleSide, device, activity, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.deviceOrientationPublisher.sink { [self] deviceOrientation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceDeviceOrientationSubject.send((insoleSide, device, deviceOrientation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.barometerPublisher.sink { [self] barometer, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceBarometerSubject.send((insoleSide, device, barometer, timestamp))
        }.store(in: &deviceCancellables[device]!)
    }

    // MARK: - barometer

    private func addDeviceBarometerSensorDataListeners(device: BSDevice) {
        device.barometerPublisher.sink { [self] barometer, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceBarometerSubject.send((insoleSide, device, barometer, timestamp))
        }.store(in: &deviceCancellables[device]!)
    }
}
