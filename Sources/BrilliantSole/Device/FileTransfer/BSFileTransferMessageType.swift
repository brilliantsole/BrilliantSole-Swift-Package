//
//  BSFileTransferMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSFileTransferMessageType: UInt8, BSEnum {
    case getFileTypes
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
