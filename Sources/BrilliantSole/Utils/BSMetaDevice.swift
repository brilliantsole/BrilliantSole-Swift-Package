//
//  BSDeviceMetadata.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/15/25.
//

import Combine

public protocol BSMetaDevice {
    var name: String { get }
    var namePublisher: AnyPublisher<String, Never> { get }

    var deviceType: BSDeviceType { get }
    var deviceTypePublisher: AnyPublisher<BSDeviceType, Never> { get }

    var ipAddress: String? { get }
    var ipAddressPublisher: AnyPublisher<String?, Never> { get }
}
