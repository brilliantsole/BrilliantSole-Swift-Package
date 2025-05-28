//
//  BSCameraConfiguration.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/25/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSCameraConfiguration", disabled: true)

public typealias BSCameraConfigurationValue = UInt16
public typealias BSCameraConfiguration = [BSCameraConfigurationType: BSCameraConfigurationValue]

extension BSCameraConfiguration {
    // MARK: - CameraConfigurationTypes

    var configurationTypes: [BSCameraConfigurationType] { keys.map { $0 }.sorted() }

    // MARK: - Parsing

    static func parse(_ data: Data) -> Self? {
        guard data.count.isMultiple(of: 3) else {
            logger?.error("Invalid data length (\(data.count)) - must be multiple of 3")
            return nil
        }

        var configuration: Self = .init()
        logger?.debug("parsing camera configuration (\(data.count) bytes)")
        for index in stride(from: 0, to: data.count, by: 3) {
            guard let cameraConfigurationType = BSCameraConfigurationType(rawValue: data[data.startIndex + index]) else {
                logger?.error("Invalid camera configuration type (\(data[index])) at index \(index)")
                continue
            }

            guard let value = BSCameraConfigurationValue.parse(data, at: index + 1) else {
                continue
            }

            logger?.debug("\(cameraConfigurationType.name): \(value)")
            configuration[cameraConfigurationType] = value
        }
        return configuration
    }

    func getData() -> Data {
        var data: Data = .init()
        for (type, value) in self {
            data += type.data
            data += value.getData(littleEndian: true)
        }
        return data
    }

    func contains(_ key: Key) -> Bool {
        keys.contains(key)
    }

    // MARK: - equality

    func isASubsetOf(_ other: Self) -> Bool {
        other.count >= count && other.keys.allSatisfy { self[$0] == other[$0] }
    }

    func isSimilarTo(_ other: Self) -> Bool {
        count > other.count ? other.isASubsetOf(self) : self.isASubsetOf(other)
    }
}
