//
//  CBPeripheral+id.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/28/25.
//

import CoreBluetooth

extension CBPeripheral {
    var id: String { identifier.uuidString }
}
