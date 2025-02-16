//
//  BSDevice+FileTransfer.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    // MARK: - setup

    internal func setupFileTransfer() {
        mtuPublisher.sink { mtu in
            self.fileTransferManager.mtu = mtu
        }.store(in: &managerCancellables)

        fileTransferManager.maxFileLengthPublisher.sink { maxFileLength in
            self.maxFileLengthSubject.send(maxFileLength)
        }.store(in: &managerCancellables)

        fileTransferManager.fileTypePublisher.sink { fileType in
            self.fileTypeSubject.send(fileType)
        }.store(in: &managerCancellables)

        fileTransferManager.fileLengthPublisher.sink { fileLength in
            self.fileLengthSubject.send(fileLength)
        }.store(in: &managerCancellables)

        fileTransferManager.fileChecksumPublisher.sink { [self] fileChecksum in
            fileChecksumSubject.send(fileChecksum)
        }.store(in: &managerCancellables)

        fileTransferManager.fileTransferStatusPublisher.sink { [self] fileTransferStatus in
            fileTransferStatusSubject.send(fileTransferStatus)
        }.store(in: &managerCancellables)

        fileTransferManager.fileTransferProgressPublisher.sink { [self] fileType, direction, progress in
            fileTransferProgressSubject.send((fileType, direction, progress))
        }.store(in: &managerCancellables)

        fileTransferManager.fileTransferCompletePublisher.sink { [self] fileType, direction in
            fileTransferCompleteSubject.send((fileType, direction))
        }.store(in: &managerCancellables)

        fileTransferManager.fileReceivedPublisher.sink { [self] fileType, data in
            fileReceivedSubject.send((fileType, data))
        }.store(in: &managerCancellables)
    }

    // MARK: - maxFileLength

    var maxFileLength: BSFileLength { fileTransferManager.maxFileLength }

    // MARK: - fileType

    var fileType: BSFileType { fileTransferManager.fileType }

    // MARK: - fileLength

    var fileLength: BSFileLength { fileTransferManager.fileLength }

    // MARK: - fileChecksum

    var fileChecksum: BSFileChecksum { fileTransferManager.fileChecksum }

    // MARK: - fileTransferStatus

    var fileTransferStatus: BSFileTransferStatus { fileTransferManager.fileTransferStatus }

    // MARK: - transfer commands

    internal func sendFile(_ file: inout BSFile, sendImmediately: Bool = true) -> Bool {
        fileTransferManager.sendFile(&file, sendImmediately: sendImmediately)
    }

    func receiveFile(type fileType: BSFileType, sendImmediately: Bool = true) {
        fileTransferManager.receiveFile(fileType: fileType, sendImmediately: sendImmediately)
    }

    func cancelFileTransfer(sendImmediately: Bool = true) {
        fileTransferManager.cancelFileTransfer(sendImmediately: sendImmediately)
    }
}
