//
//  BSDiscoveredDeviceJson.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/26/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger
struct BSDiscoveredDeviceJson: Codable {
    let id: String
    let name: String
    let rssi: Int
    let deviceTypeString: String
    var deviceType: BSDeviceType? {
        .init(name: deviceTypeString)
    }

    enum CodingKeys: String, CodingKey {
        case id = "bluetoothId"
        case name
        case rssi
        case deviceTypeString = "deviceType"
    }

    init?(jsonString: String) {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                self = try JSONDecoder().decode(Self.self, from: jsonData)
            } catch {
                Self.logger.error("error decoding JSON: \(error)")
                return nil
            }
        } else {
            Self.logger.error("unable to convert jsonString to data")
            return nil
        }
    }
}
