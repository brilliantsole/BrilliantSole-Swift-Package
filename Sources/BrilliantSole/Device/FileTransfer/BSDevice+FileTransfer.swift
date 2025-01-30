//
//  BSDevice+FileTransfer.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

extension BSDevice {
    // MARK: - setup

    func setupFileTransfer() {
        mtuPublisher.sink { [weak self] mtu in
            self?.fileTransferManager.mtu = mtu
        }.store(in: &managerCancellables)
    }

    // MARK: - transfer commands

    func sendFile(_ file: inout BSFile, sendImmediately: Bool = true) -> Bool {
        fileTransferManager.sendFile(&file, sendImmediately: sendImmediately)
    }

    public func receiveFile(type fileType: BSFileType, sendImmediately: Bool = true) {
        fileTransferManager.receiveFile(fileType: fileType, sendImmediately: sendImmediately)
    }

    public func cancelFileTransfer(sendImmediately: Bool = true) {
        fileTransferManager.cancelFileTransfer(sendImmediately: sendImmediately)
    }

    // MARK: - fileTransferStatus

    var fileTransferStatus: BSFileTransferStatus { fileTransferManager.fileTransferStatus }
    var fileTransferStatusPublisher: AnyPublisher<BSFileTransferStatus, Never> {
        fileTransferManager.fileTransferStatusPublisher
    }
}
