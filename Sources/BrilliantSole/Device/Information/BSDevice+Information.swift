//
//  BSDevice+Information.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    internal func setupInformationManager() {
        informationManager.idPublisher.sink { id in
            self.idSubject.send(id)
        }.store(in: &managerCancellables)

        informationManager.mtuPublisher.sink { mtu in
            self.mtuSubject.send(mtu)
        }.store(in: &managerCancellables)

        informationManager.deviceTypePublisher.sink { deviceType in
            self.deviceTypeSubject.send(deviceType)
        }.store(in: &managerCancellables)

        informationManager.namePublisher.sink { name in
            self.nameSubject.send(name)
        }.store(in: &managerCancellables)
    }

    // MARK: - id

    var id: String { informationManager.id }

    // MARK: - mtu

    var mtu: BSMtu { informationManager.mtu }

    // MARK: - deviceType

    var deviceType: BSDeviceType { informationManager.deviceType }

    var isInsole: Bool { deviceType.isInsole }
    var insoleSide: BSInsoleSide? { deviceType.insoleSide }

    // MARK: - name

    var name: String { informationManager.name }
}
