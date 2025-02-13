//
//  BSDeviceMetadata.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/13/25.
//

import Combine

public protocol BSDeviceMetadata {
    // MARK: - name

    var name: String { get }
    var namePublisher: AnyPublisher<(Self, String), Never> { get }

    // MARK: - deviceType

    var deviceType: BSDeviceType { get }
    var deviceTypePublisher: AnyPublisher<(Self, BSDeviceType), Never> { get }

    // MARK: - device

    var device: BSDevice? { get }
}
