//
//  BSDevice+DeviceInformation.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/2/25.
//

extension BSDevice {
    func setupDeviceInformationManager() {
        deviceInformationManager.deviceInformationPublisher.sink { [self] deviceInformation in
            self.deviceInformationSubject.send(deviceInformation)
        }.store(in: &managerCancellables)
    }
}
