//
//  BSBleUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import CoreBluetooth
import UkatonMacros

private let logger = getLogger(category: "BSBleUtils")

@EnumName
enum BSBleUUIDType {
    case batteryLevel
    case deviceInformation
    case main
    case smp
}

protocol BSBleUUID: Hashable, Sendable, CaseIterable, RawRepresentable where RawValue == String {
    var name: String { get }
    var uuidString: String { get }
    var uuid: CBUUID { get }

    static var uuids: [Self: CBUUID] { get }
    static var allUuids: [CBUUID] { get }

    var type: BSBleUUIDType { get }
    static func cases(for type: BSBleUUIDType) -> [Self]
}

extension BSBleUUID {
    var uuidString: String {
        switch type {
        case .main:
            "ea6da725-\(rawValue)-4f9b-893d-c3913e33b39f"
        default:
            rawValue
        }
    }

    var uuid: CBUUID { Self.uuids[self]! }

    static var allUuids: [CBUUID] { allCases.map(\.uuid) }

    static func cases(for type: BSBleUUIDType) -> [Self] {
        allCases.compactMap { $0.type == type ? $0 : nil }
    }

    static func initializeUUIDs() -> [Self: CBUUID] {
        allCases.reduce(into: [Self: CBUUID]()) { result, value in
            result[value] = CBUUID(string: value.uuidString)
        }
    }
}

@EnumName
enum BSBleServiceUUID: String, BSBleUUID {
    nonisolated(unsafe) static let uuids: [Self: CBUUID] = initializeUUIDs()

    case batteryLevel = "0x180F"
    case deviceInformation = "0x180A"
    case main = "0000"
    case smp = "8d53dc1d-1db7-4cd3-868b-8a527460aa84"

    var type: BSBleUUIDType {
        switch self {
        case .batteryLevel:
            .batteryLevel
        case .deviceInformation:
            .deviceInformation
        case .main:
            .main
        case .smp:
            .smp
        }
    }

    var characteristics: [BSBleCharacteristicUUID] { BSBleCharacteristicUUID.cases(for: type) }
    var characteristicUUIDs: [CBUUID] { characteristics.map(\.uuid) }

    init?(service: CBService) {
        guard let value = Self.allCases.first(where: { $0.uuid == service.uuid }) else {
            logger.error("unknown service \(service.uuid)")
            return nil
        }
        self = value
    }
}

@EnumName
enum BSBleCharacteristicUUID: String, BSBleUUID {
    nonisolated(unsafe) static let uuids: [Self: CBUUID] = initializeUUIDs()

    case batteryLevel = "0x2A19"

    case systemIdString = "0x2A23"
    case modelNumberString = "0x2A24"
    case serialNumberString = "0x2A25"
    case firmwareRevisionString = "0x2A26"
    case hardwareRevisionString = "0x2A27"
    case softwareRevisionString = "0x2A28"
    case manufacturerNameString = "0x2A29"

    case rx = "1000"
    case tx = "1001"

    case smp = "da2e7828-fbce-4e01-ae9e-261174997c48"

    var type: BSBleUUIDType {
        switch self {
        case .batteryLevel:
            .batteryLevel
        case let s where s.isDeviceInformation:
            .deviceInformation
        case .smp:
            .smp
        case .tx, .rx:
            .main
        default:
            fatalError("uncaught case: \(self)")
        }
    }

    var writeType: CBCharacteristicWriteType {
        switch self {
        case .smp:
            .withResponse
        case .tx:
            .withResponse
        default:
            .withoutResponse
        }
    }

    var deviceInformationType: BSDeviceInformationType? {
        switch self {
        case .systemIdString:
            .systemIdString
        case .modelNumberString:
            .modelNumberString
        case .serialNumberString:
            .serialNumberString
        case .firmwareRevisionString:
            .firmwareRevisionString
        case .hardwareRevisionString:
            .hardwareRevisionString
        case .softwareRevisionString:
            .softwareRevisionString
        case .manufacturerNameString:
            .manufacturerNameString
        default:
            nil
        }
    }

    var isDeviceInformation: Bool {
        deviceInformationType != nil
    }

    var readOnConnection: Bool {
        switch self {
        default:
            true
        }
    }

    var notifyOnConnection: Bool {
        switch self {
        case .smp:
            false
        default:
            true
        }
    }

    var service: BSBleServiceUUID { BSBleServiceUUID.cases(for: type).first! }

    init?(characteristic: CBCharacteristic) {
        guard let value = Self.allCases.first(where: { $0.uuid == characteristic.uuid }) else {
            logger.error("unknown characteristic \(characteristic.uuid)")
            return nil
        }
        self = value
    }
}
