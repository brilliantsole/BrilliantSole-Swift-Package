//
//  BSTxRxMessageUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSTxRxMessageUtils {
    static let BSManagers: [any BSManager.Type] = [
        BSBatteryManager.self,
        BSInformationManager.self,
        BSSensorConfigurationManager.self,
        BSSensorDataManager.self,
        BSVibrationManager.self,
        BSTfliteManager.self,
        BSFileTransferManager.self,
    ]

    static let enumStrings: [String] = {
        var enumStrings: [String] = .init()
        var offset: UInt8 = 0
        for manager in BSManagers {
            manager.initTxRxEnum(offset: &offset, enumStrings: &enumStrings)
        }
        return enumStrings
    }()

    static let enumStringMap: [String: UInt8] = {
        var enumStringMap: [String: UInt8] = .init()
        for (index, enumString) in enumStrings.enumerated() {
            enumStringMap[enumString] = UInt8(index)
        }
        return enumStringMap
    }()

    static let requiredTxRxMessageTypes: [UInt8] = {
        var requiredTxRxMessageTypes: [UInt8] = .init()
        for manager in BSManagers {
            requiredTxRxMessageTypes += manager.requiredTxRxMessageTypes
        }
        return requiredTxRxMessageTypes
    }()

    static let requiredTxRxMessages: [BSTxMessage] = {
        var requiredTxRxMessages: [BSTxMessage] = .init()
        for requiredTxRxMessageType in requiredTxRxMessageTypes {
            requiredTxRxMessages.append(.init(type: requiredTxRxMessageType))
        }
        return requiredTxRxMessages
    }()
}
