//
//  BSBleConnectionManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/25/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSBleConnectionManager: BSBaseConnectionManager {
    override class var connectionType: BSConnectionType { .ble }
}
