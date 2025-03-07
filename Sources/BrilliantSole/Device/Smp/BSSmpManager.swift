//
//  BSSmpManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
final class BSSmpManager: BSBaseManager<BSSmpMessageType> {
    override class var requiredMessageTypes: [BSSmpMessageType]? {
        [
            .smp
        ]
    }

    override func onRxMessage(_ messageType: BSSmpMessageType, data: Data) {
        switch messageType {
        case .smp:
            break
        }
    }
}
