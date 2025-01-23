//
//  BSFileTransferManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSFileTransferManager: BSBaseManager<BSFileTransferMessageType> {
    override class var requiredMessageTypes: [BSFileTransferMessageType]? {
        [.getMaxFileLength,
         .getFileTransferType,
         .getFileLength,
         .getFileChecksum,
         .getFileTransferStatus]
    }

    override func onRxMessage(_ messageType: BSFileTransferMessageType, data: Data) {
        switch messageType {
        case .getMaxFileLength:
            print("FILL")
        case .getFileTransferType:
            print("FILL")
        case .setFileTransferType:
            print("FILL")
        case .getFileLength:
            print("FILL")
        case .setFileLength:
            print("FILL")
        case .getFileChecksum:
            print("FILL")
        case .setFileChecksum:
            print("FILL")
        case .setFileTransferCommand:
            print("FILL")
        case .getFileTransferStatus:
            print("FILL")
        case .getFileTransferBlock:
            print("FILL")
        case .setFileTransferBlock:
            print("FILL")
        case .fileBytesTransferred:
            print("FILL")
        }
    }
}
