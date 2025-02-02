//
//  BSDevice+DeviceInformation.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/2/25.
//

extension BSDevice {
    func setupDeviceInformationManager() {
        deviceInformationManager.deviceInformationPublisher.sink { [weak self] deviceInformation in
            self?.deviceInformation = deviceInformation
        }.store(in: &managerCancellables)
    }
}
