//
//  BSFileType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSFileType: UInt8, BSEnum {
    case tflite
    case wifiServerCertificate
    case wifiServerKey

    var fileExtension: String {
        switch self {
        case .tflite:
            return "tflite"
        case .wifiServerCertificate, .wifiServerKey:
            return "pem"
        }
    }
}

public typealias BSFileTypes = Set<BSFileType>

extension Collection where Element == BSFileType {
    static func parse(_ data: Data) -> BSFileTypes? {
        var set: BSFileTypes = []
        for rawValue in data {
            guard let value = Element(rawValue: rawValue) else {
                continue
            }
            set.insert(value)
        }
        return set
    }
}
