//
//  BSDeviceInformation.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import OSLog
import UkatonMacros

@StaticLogger
struct BSDeviceInformation {
    private var dictionary: [BSDeviceInformationType: String] = .init()
    public private(set) var hasAllInformation: Bool = false

    subscript(key: BSDeviceInformationType) -> String? {
        get {
            return dictionary[key]
        }
        set {
            dictionary[key] = newValue
            updateHasAllInformation()
        }
    }

    mutating func remove() {
        dictionary.removeAll()
        hasAllInformation = false
    }

    private mutating func updateHasAllInformation() {
        let missingKey = BSDeviceInformationType.allCases.first {
            !dictionary.keys.contains($0)
        }

        if missingKey != nil {
            logger.debug("missing deviceInformationType \(missingKey!.name)")
        }

        let newHasAllInformation = missingKey == nil
        if newHasAllInformation == hasAllInformation {
            return
        }

        hasAllInformation = newHasAllInformation
        logger.debug("updated hasAllInformation to \(newHasAllInformation)")
    }
}
