//
//  BSFileTransferDirection.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSFileTransferDirection: UInt8, CaseIterable {
    case sending
    case receiving
}
