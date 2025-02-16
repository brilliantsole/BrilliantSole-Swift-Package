//
//  BSDeviceMetadata.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/15/25.
//

import Combine

public protocol BSDeviceMetadata {
    associatedtype DeviceMetadataType

    var name: String { get }
    var namePublisher: AnyPublisher<(DeviceMetadataType, String), Never> { get }

    var deviceType: BSDeviceType { get }
    var deviceTypePublisher: AnyPublisher<(DeviceMetadataType, BSDeviceType), Never> { get }
}
