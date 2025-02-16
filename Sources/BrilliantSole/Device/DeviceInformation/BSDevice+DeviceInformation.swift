//
//  BSDevice+DeviceInformation.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/2/25.
//

import Combine

public extension BSDevice {
    internal func setupDeviceInformationManager() {}

    var deviceInformation: BSDeviceInformation { deviceInformationManager.deviceInformation }

    var deviceInformationPublisher: AnyPublisher<BSDeviceInformation, Never> { deviceInformationManager.deviceInformationPublisher.eraseToAnyPublisher() }
}
