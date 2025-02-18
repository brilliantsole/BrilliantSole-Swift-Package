//
//  BSDeviceInformation.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Combine
import OSLog
import UkatonMacros

public typealias BSDeviceInformationValue = String
public typealias BSDeviceInformation = [BSDeviceInformationType: BSDeviceInformationValue]

let mockDeviceInformation: BSDeviceInformation = [
    .modelNumberString: "BrilliantSole",
    .firmwareRevisionString: "v0.0.0",
    .hardwareRevisionString: "1",
    .softwareRevisionString: "1",
    .manufacturerNameString: "Brilliant Sole, Inc.",
    .serialNumberString: "0"
]

@StaticLogger(disabled: true)
class BSDeviceInformationManager {
    internal(set) var deviceInformation: BSDeviceInformation = .init()

    private let deviceInformationSubject: PassthroughSubject<BSDeviceInformation, Never> = .init()
    var deviceInformationPublisher: AnyPublisher<BSDeviceInformation, Never> {
        deviceInformationSubject.eraseToAnyPublisher()
    }

    private(set) var hasAllInformation: Bool = false {
        didSet {
            guard oldValue != hasAllInformation else {
                return
            }
            if hasAllInformation {
                logger?.debug("got all deviceInformation")
                deviceInformationSubject.send(deviceInformation)
            }
        }
    }

    public subscript(key: BSDeviceInformationType) -> BSDeviceInformationValue? {
        get {
            return deviceInformation[key]
        }
        set {
            deviceInformation[key] = newValue
            updateHasAllInformation()
        }
    }

    func reset() {
        deviceInformation.removeAll()
        hasAllInformation = false
    }

    private func updateHasAllInformation() {
        let missingKey = BSDeviceInformationType.allCases.filter(\.isRequired).first {
            !deviceInformation.keys.contains($0)
        }

        if missingKey != nil {
            logger?.debug("missing deviceInformationType \(missingKey!.name)")
        }

        let newHasAllInformation = missingKey == nil
        if newHasAllInformation == hasAllInformation {
            return
        }

        hasAllInformation = newHasAllInformation
        logger?.debug("updated hasAllInformation to \(newHasAllInformation)")
    }
}
