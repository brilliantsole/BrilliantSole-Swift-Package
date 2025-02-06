//
//  BSConnectedDevicesJson.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger
struct BSConnectedDevicesJson: Codable {
    let connectedDeviceIds: [String]

    enum CodingKeys: String, CodingKey {
        case connectedDeviceIds = "connectedDevices"
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

    init?(data: Data) {
        guard let jsonString = BSStringUtils.getString(from: data, includesLength: true) else {
            return nil
        }
        self.init(jsonString: jsonString)
    }
}
