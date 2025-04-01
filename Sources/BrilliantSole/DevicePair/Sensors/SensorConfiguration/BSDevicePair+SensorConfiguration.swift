//
//  BSDevicePair+SensorConfiguration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

public extension BSDevicePair
{
    internal func addDeviceSensorConfigurationListeners(device: BSDevice)
    {
        device.sensorConfigurationPublisher.sink
        { sensorConfiguration in
            guard let side = self.getDeviceSide(device) else { return }
            self.deviceSensorConfigurationSubject.send((side, device, sensorConfiguration))
        }.store(in: &deviceCancellables[device]!)
    }

    func setSensorConfiguration(_ sensorConfiguration: BSSensorConfiguration, clearRest: Bool = false, sendImmediately: Bool = true)
    {
        devices.forEach { $0.value.setSensorConfiguration(sensorConfiguration, clearRest: clearRest, sendImmediately: sendImmediately) }
    }

    func setSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate, sendImmediately: Bool = true)
    {
        devices.forEach { $0.value.setSensorRate(sensorType: sensorType, sensorRate: sensorRate, sendImmediately: sendImmediately) }
    }

    func clearSensorRate(sensorType: BSSensorType, sendImmediately: Bool = true)
    {
        devices.forEach { $0.value.clearSensorRate(sensorType: sensorType, sendImmediately: sendImmediately) }
    }

    func toggleSensorRate(sensorType: BSSensorType, sensorRate: BSSensorRate, sendImmediately: Bool = true)
    {
        devices.forEach { $0.value.toggleSensorRate(sensorType: sensorType, sensorRate: sensorRate, sendImmediately: sendImmediately) }
    }

    func clearSensorConfiguration(sendImmediately: Bool = true)
    {
        devices.forEach { $0.value.clearSensorConfiguration(sendImmediately: sendImmediately) }
    }
}
