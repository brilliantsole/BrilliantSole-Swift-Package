//
//  BSDevice+Information.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    // MARK: - id

    var idPublisher: AnyPublisher<String, Never> {
        informationManager.idPublisher
    }

    nonisolated var id: String { informationManager.id }

    // MARK: - mtu

    var mtu: BSMtu { informationManager.mtu }
    var mtuPublisher: AnyPublisher<BSMtu, Never> {
        informationManager.mtuPublisher
    }

    // MARK: - deviceType

    var deviceType: BSDeviceType { informationManager.deviceType }
    var deviceTypePublisher: AnyPublisher<BSDeviceType, Never> {
        informationManager.deviceTypePublisher
    }

    var isInsole: Bool { deviceType.isInsole }
    var insoleSide: BSInsoleSide? { deviceType.insoleSide }

    // MARK: - name

    var name: String { informationManager.name }
    var namePublisher: AnyPublisher<String, Never> {
        informationManager.namePublisher
    }
}
