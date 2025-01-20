//
//  BSFileTransferEventType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSFileTransferEventType: UInt8, CaseIterable {
    case fileTransferProgress
    case fileTransferComplete
    case fileReceived
}
