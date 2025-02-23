//
//  BSDevice+FileTransfer.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine
import Foundation

public extension BSDevice {
    // MARK: - setup

    internal func setupFileTransfer() {}

    // MARK: - maxFileLength

    var maxFileLength: BSFileLength { fileTransferManager.maxFileLength }
    var maxFileLengthPublisher: AnyPublisher<BSFileLength, Never> { fileTransferManager.maxFileLengthPublisher }

    // MARK: - fileType

    var fileType: BSFileType { fileTransferManager.fileType }
    var fileTypePublisher: AnyPublisher<BSFileType, Never> { fileTransferManager.fileTypePublisher }

    // MARK: - fileLength

    var fileLength: BSFileLength { fileTransferManager.fileLength }
    var fileLengthPublisher: AnyPublisher<BSFileLength, Never> { fileTransferManager.fileLengthPublisher }

    // MARK: - fileChecksum

    var fileChecksum: BSFileChecksum { fileTransferManager.fileChecksum }
    var fileChecksumPublisher: AnyPublisher<BSFileChecksum, Never> { fileTransferManager.fileChecksumPublisher }

    // MARK: - fileTransferStatus

    var fileTransferStatus: BSFileTransferStatus { fileTransferManager.fileTransferStatus }
    var fileTransferStatusPublisher: AnyPublisher<BSFileTransferStatus, Never> { fileTransferManager.fileTransferStatusPublisher }

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

    // MARK: - publishers

    var fileTransferProgressPublisher: BSFileTransferProgressPublisher {
        fileTransferManager.fileTransferProgressPublisher
    }

    var fileReceivedPublisher: BSFileReceivedPublisher {
        fileTransferManager.fileReceivedPublisher
    }

    var fileTransferCompletePublisher: BSFileTransferCompletePublisher {
        fileTransferManager.fileTransferCompletePublisher
    }
}
