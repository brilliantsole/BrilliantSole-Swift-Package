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
            guard let side = getDeviceSide(device) else { return }
            devicePressureDataSubject.send((side, device, pressureData, timestamp))
            sensorDataManager.pressureSensorDataManager.onDevicePressureData(side: side, pressureData: pressureData, timestamp: timestamp)
        }.store(in: &deviceCancellables[device]!)
    }

    // MARK: - motion

    private func addDeviceMotionSensorDataListeners(device: BSDevice) {
        device.accelerationPublisher.sink { [self] acceleration, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceAccelerationSubject.send((side, device, acceleration, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gravityPublisher.sink { [self] gravity, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceGravitySubject.send((side, device, gravity, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.linearAccelerationPublisher.sink { [self] linearAcceleration, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceLinearAccelerationSubject.send((side, device, linearAcceleration, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gyroscopePublisher.sink { [self] gyroscope, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceGyroscopeSubject.send((side, device, gyroscope, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.magnetometerPublisher.sink { [self] magnetometer, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceMagnetometerSubject.send((side, device, magnetometer, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.gameRotationPublisher.sink { [self] gameRotation, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceGameRotationSubject.send((side, device, gameRotation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.rotationPublisher.sink { [self] rotation, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceRotationSubject.send((side, device, rotation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.orientationPublisher.sink { [self] orientation, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceOrientationSubject.send((side, device, orientation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.stepCountPublisher.sink { [self] stepCount, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceStepCountSubject.send((side, device, stepCount, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.stepDetectionPublisher.sink { [self] timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceStepDetectionSubject.send((side, device, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.activityPublisher.sink { [self] activity, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceActivitySubject.send((side, device, activity, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.deviceOrientationPublisher.sink { [self] deviceOrientation, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceDeviceOrientationSubject.send((side, device, deviceOrientation, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.barometerPublisher.sink { [self] barometer, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceBarometerSubject.send((side, device, barometer, timestamp))
        }.store(in: &deviceCancellables[device]!)

        device.tapDetectionPublisher.sink { [self] timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceTapDetectionSubject.send((side, device, timestamp))
        }.store(in: &deviceCancellables[device]!)
    }

    // MARK: - barometer

    private func addDeviceBarometerSensorDataListeners(device: BSDevice) {
        device.barometerPublisher.sink { [self] barometer, timestamp in
            guard let side = getDeviceSide(device) else { return }
            deviceBarometerSubject.send((side, device, barometer, timestamp))
        }.store(in: &deviceCancellables[device]!)
    }
}
