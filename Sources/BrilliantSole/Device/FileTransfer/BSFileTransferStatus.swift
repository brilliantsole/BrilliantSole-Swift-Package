//
//  BSFileTransferStatus.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSFileTransferStatus: UInt8, CaseIterable {
    case idle
    case sending
    case receiving
}
