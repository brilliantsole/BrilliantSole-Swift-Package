//
//  BSServerMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
enum BSServerMessageType: UInt8, BSEnum {
    case isScanningAvailable
    case isScanning
    case startScan
    case stopScan
    case discoveredDevice
    case discoveredDevices
    case expiredDiscoveredDevice
    case connectToDevice
    case disconnectFromDevice
    case connectedDevices
    case deviceMessage
}
