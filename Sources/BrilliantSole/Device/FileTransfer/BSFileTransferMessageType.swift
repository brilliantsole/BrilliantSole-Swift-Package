//
//  BSFileTransferMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSFileTransferMessageType: UInt8, CaseIterable {
    case getMaxFileLength
    case getFileTransferType
    case setFileTransferType
    case getFileLength
    case setFileLength
    case getFileChecksum
    case setFileChecksum
    case setFileTransferCommand
    case getFileTransferStatus
    case getFileTransferBlock
    case setFileTransferBlock
    case fileBytesTransferred
}
