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
        device.pressureDataPublisher.sink { [self] device, pressureData, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            devicePressureDataSubject.send((self, insoleSide, device, pressureData, timestamp))
            sensorDataManager.pressureSensorDataManager.onDevicePressureData(insoleSide: insoleSide, pressureData: pressureData, timestamp: timestamp)
        }.store(in: &deviceCancellables[device]!)
    }

    // MARK: - motion

    private func addDeviceMotionSensorDataListeners(device: BSDevice) {
        device.accelerationPublisher.sink { [self] device, acceleration, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceAccelerationSubject.send((self, insoleSide, device, acceleration, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gravityPublisher.sink { [self] device, gravity, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceGravitySubject.send((self, insoleSide, device, gravity, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.linearAccelerationPublisher.sink { [self] device, linearAcceleration, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceLinearAccelerationSubject.send((self, insoleSide, device, linearAcceleration, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gyroscopePublisher.sink { [self] device, gyroscope, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceGyroscopeSubject.send((self, insoleSide, device, gyroscope, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.magnetometerPublisher.sink { [self] device, magnetometer, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceMagnetometerSubject.send((self, insoleSide, device, magnetometer, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gameRotationPublisher.sink { [self] device, gameRotation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceGameRotationSubject.send((self, insoleSide, device, gameRotation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.rotationPublisher.sink { [self] device, rotation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceRotationSubject.send((self, insoleSide, device, rotation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.orientationPublisher.sink { [self] device, orientation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceOrientationSubject.send((self, insoleSide, device, orientation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.stepCountPublisher.sink { [self] device, stepCount, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceStepCountSubject.send((self, insoleSide, device, stepCount, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.stepDetectionPublisher.sink { [self] device, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceStepDetectionSubject.send((self, insoleSide, device, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.activityPublisher.sink { [self] device, activity, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceActivitySubject.send((self, insoleSide, device, activity, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.deviceOrientationPublisher.sink { [self] device, deviceOrientation, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceDeviceOrientationSubject.send((self, insoleSide, device, deviceOrientation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.barometerPublisher.sink { [self] device, barometer, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceBarometerSubject.send((self, insoleSide, device, barometer, timestamp))
        }.store(in: &deviceCancellables[device]!)
    }

    // MARK: - barometer

    private func addDeviceBarometerSensorDataListeners(device: BSDevice) {
        device.barometerPublisher.sink { [self] device, barometer, timestamp in
            guard let insoleSide = getDeviceInsoleSide(device) else { return }
            deviceBarometerSubject.send((self, insoleSide, device, barometer, timestamp))
        }.store(in: &deviceCancellables[device]!)
    }
}
