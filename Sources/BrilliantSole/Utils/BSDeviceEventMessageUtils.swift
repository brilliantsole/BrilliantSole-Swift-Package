//
//  BSDeviceEventMessageUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger
final class BSDeviceEventMessageUtils {
    static let enumStrings: [String] = initializeEnumStrings()
    static let enumStringMap: [String: UInt8] = initializeEnumStringMap()

    private static func initializeEnumStrings() -> [String] {
        logger.debug("initializeEnumStrings")
        var enumStrings: [String] = []
        var offset: UInt8 = 0
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSConnectionMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSConnectionStatus.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSConnectionEventType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSMetaConnectionMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSBatteryLevelMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSBatteryMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSInformationMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSDeviceInformationType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSDeviceInformationEventType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSSensorConfigurationMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSSensorDataMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSSensorType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSFileTransferMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSFileTransferEventType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSTfliteMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSSmpMessageType.self)
        appendEnum(offset: &offset, enumStrings: &enumStrings, enum: BSSmpEventType.self)
        logger.debug("enumStrings: \(enumStrings)")
        return enumStrings
    }

    private static func initializeEnumStringMap() -> [String: UInt8] {
        logger.debug("initializeEnumStringMap")
        var enumStringMap: [String: UInt8] = [:]
        for (index, enumString) in enumStrings.enumerated() {
            enumStringMap[enumString] = UInt8(index)
        }
        logger.debug("enumStringMap: \(enumStringMap)")
        return enumStringMap
    }

    private static func appendEnum<TEnum: BSNamedEnum & CaseIterable>(offset: inout UInt8, enumStrings: inout [String], enum: TEnum.Type) {
        let names = TEnum.allCases.map { $0.name }
        appendStrings(offset: &offset, enumStrings: &enumStrings, names: names)
    }

    private static func appendStrings(offset: inout UInt8, enumStrings: inout [String], names: [String]) {
        for name in names {
            enumStrings.append(name)
            offset += 1
        }
    }

    static func stringArrayToData(_ strings: [String]) -> Data {
        var data: Data = .init()
        for string in strings {
            guard let value = enumStringMap[string] else {
                logger.error("no value found for enum \(string)")
                continue
            }
            data.append(value)
        }
        return data
    }
}
