//
//  BSDevicePair+Tflite.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

public extension BSDevicePair {
    internal func addDeviceTfliteListeners(device: BSDevice) {
        device.isTfliteReadyPublisher.sink { [self] isTfliteReady in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            self.deviceIsTfliteReadySubject.send(( insoleSide, device, isTfliteReady))
        }.store(in: &deviceCancellables[device]!)

        device.tfliteInferencingEnabledPublisher.sink { [self] tfliteInferencingEnabled in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            self.deviceTfliteInferencingEnabledSubject.send(( insoleSide, device, tfliteInferencingEnabled))
        }.store(in: &deviceCancellables[device]!)

        device.tfliteInferencePublisher.sink { [self] tfliteInference in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            self.deviceTfliteInferenceSubject.send(( insoleSide, device, tfliteInference))
        }.store(in: &deviceCancellables[device]!)

        device.tfliteClassificationPublisher.sink { [self] tfliteClassification in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            self.deviceTfliteClassificationSubject.send(( insoleSide, device, tfliteClassification))
        }.store(in: &deviceCancellables[device]!)
    }

    func setTfliteInferencingEnabled(_ inferencingEnabled: Bool, sendImmediately: Bool = true) {
        devices.forEach { $0.value.setTfliteInferencingEnabled(inferencingEnabled, sendImmediately: sendImmediately) }
    }
}
