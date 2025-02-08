//
//  BSTxRxMessageUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
final class BSTxRxMessageUtils {
    static let BSManagers: [any BSManager.Type] = [
        BSBatteryManager.self,
        BSInformationManager.self,
        BSSensorConfigurationManager.self,
        BSSensorDataManager.self,
        BSVibrationManager.self,
        BSTfliteManager.self,
        BSFileTransferManager.self,
    ]

    static let enumStrings: [String] = initializeEnumStrings()
    static let enumStringMap: [String: UInt8] = initializeEnumStringMap()
    static let requiredTxRxMessageTypes: [UInt8] = initializeRequiredTxRxMessageTypes()
    static let requiredTxRxMessages: [BSTxMessage] = initializeRequiredTxRxMessages()

    private static func initializeEnumStrings() -> [String] {
        logger?.debug("initializeEnumStrings")
        var enumStrings: [String] = []
        var offset: UInt8 = 0
        for manager in BSManagers {
            manager.initTxRxEnum(at: &offset, enumStrings: &enumStrings)
        }
        logger?.debug("enumStrings: \(enumStrings)")
        return enumStrings
    }

    private static func initializeEnumStringMap() -> [String: UInt8] {
        logger?.debug("initializeEnumStringMap")
        var enumStringMap: [String: UInt8] = [:]
        for (index, enumString) in enumStrings.enumerated() {
            enumStringMap[enumString] = UInt8(index)
        }
        logger?.debug("enumStringMap \(enumStringMap)")
        return enumStringMap
    }

    private static func initializeRequiredTxRxMessageTypes() -> [UInt8] {
        logger?.debug("initializeRequiredTxRxMessageTypes")
        var requiredTxRxMessageTypes: [UInt8] = []
        for manager in BSManagers {
            requiredTxRxMessageTypes += manager.requiredTxRxMessageTypes
        }
        logger?.debug("requiredTxRxMessageTypes: \(requiredTxRxMessageTypes)")
        return requiredTxRxMessageTypes
    }

    private static func initializeRequiredTxRxMessages() -> [BSTxMessage] {
        _ = enumStringMap
        logger?.debug("initializeRequiredTxRxMessages")
        var requiredTxRxMessages: [BSTxMessage] = []
        for requiredTxRxMessageType in requiredTxRxMessageTypes {
            requiredTxRxMessages.append(.init(type: requiredTxRxMessageType))
        }
        return requiredTxRxMessages
    }
}
