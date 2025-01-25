//
//  BSFileTransferManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
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
            parseMaxFileLength(data)
        case .getFileTransferType, .setFileTransferType:
            parseFileTransferType(data)
        case .getFileLength, .setFileLength:
            parseFileLength(data)
        case .getFileChecksum, .setFileChecksum:
            parseChecksum(data)
        case .setFileTransferCommand:
            break
        case .getFileTransferStatus:
            parseFileTransferStatus(data)
        case .getFileTransferBlock:
            parseFileTransferBlock(data)
        case .setFileTransferBlock:
            break
        case .fileBytesTransferred:
            parseFileBytesTransferred(data)
        }
    }

    override func reset() {
        super.reset()
        maxFileLength = 0
        fileType = .tflite
        fileLength = 0
        fileChecksum = 0
        fileTransferStatus = .idle

        mtu = 0

        fileDataToReceive.removeAll(keepingCapacity: true)
        fileDataToSend = nil

        bytesTransferred = 0
        waitingToSendMoreData = false
    }

    // MARK: - maxFileLength

    let maxFileLengthSubject: CurrentValueSubject<UInt16, Never> = .init(0)
    var maxFileLength: UInt16 {
        get { maxFileLengthSubject.value }
        set {
            maxFileLengthSubject.value = newValue
            logger.debug("updated maxFileLength to \(newValue)")
        }
    }

    func getMaxFileLength(sendImmediately: Bool = true) {
        logger.debug("getting maxFileLength")
        createAndSendMessage(.getMaxFileLength, sendImmediately: sendImmediately)
    }

    func parseMaxFileLength(_ data: Data) {
        let newMaxFileLength: UInt16 = .parse(data)
        logger.debug("parsed maxFileLength \(newMaxFileLength)")
        maxFileLength = newMaxFileLength
    }

    // MARK: - fileTransferType

    let fileTypeSubject: CurrentValueSubject<BSFileType, Never> = .init(.tflite)
    var fileType: BSFileType {
        get { fileTypeSubject.value }
        set {
            fileTypeSubject.value = newValue
            logger.debug("updated fileType to \(newValue.name)")
        }
    }

    func getFileType(sendImmediately: Bool = true) {
        logger.debug("getting fileTransferType")
        createAndSendMessage(.getFileTransferType, sendImmediately: sendImmediately)
    }

    func parseFileTransferType(_ data: Data) {
        guard let newFileType = BSFileType.parse(data) else {
            return
        }
        logger.debug("parsed fileType \(newFileType.name)")
        fileType = newFileType
    }

    func setFileTransferType(_ newFileType: BSFileType, sendImmediately: Bool = true) {
        guard fileType != newFileType else {
            logger.debug("redundant fileType assignment \(newFileType.name)")
            return
        }
        createAndSendMessage(.setFileTransferType, data: newFileType.data, sendImmediately: sendImmediately)
    }

    // MARK: - fileLength

    let fileLengthSubject: CurrentValueSubject<UInt16, Never> = .init(0)
    var fileLength: UInt16 {
        get { fileLengthSubject.value }
        set {
            fileLengthSubject.value = newValue
            logger.debug("updated fileLength to \(newValue)")
        }
    }

    func getFileLength(sendImmediately: Bool = true) {
        logger.debug("getting fileLength")
        createAndSendMessage(.getFileLength, sendImmediately: sendImmediately)
    }

    func parseFileLength(_ data: Data) {
        let newFileLength: UInt16 = .parse(data)
        logger.debug("parsed fileLength \(newFileLength)")
        fileLength = newFileLength
    }

    func setFileLength(_ newFileLength: UInt16, sendImmediately: Bool = true) {
        guard newFileLength != fileLength else {
            logger.debug("redundant fileLength assignment \(newFileLength)")
            return
        }
        createAndSendMessage(.setFileLength, data: newFileLength.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - fileChecksum

    let fileChecksumSubject: CurrentValueSubject<BSFileChecksum, Never> = .init(0)
    var fileChecksum: BSFileChecksum {
        get { fileChecksumSubject.value }
        set {
            fileChecksumSubject.value = newValue
            logger.debug("updated checksum to \(newValue)")
        }
    }

    func getFileChecksum(sendImmediately: Bool = true) {
        logger.debug("getting fileChecksum")
        createAndSendMessage(.getFileChecksum, sendImmediately: sendImmediately)
    }

    func parseChecksum(_ data: Data) {
        let newFileChecksum: BSFileChecksum = .parse(data)
        logger.debug("parsed fileChecksum \(newFileChecksum)")
        fileChecksum = newFileChecksum
    }

    func setChecksum(_ newFileChecksum: BSFileChecksum, sendImmediately: Bool = true) {
        guard newFileChecksum != fileChecksum else {
            logger.debug("redundant checksum assignment \(newFileChecksum)")
            return
        }
        logger.debug("setting checksum \(newFileChecksum)")
        createAndSendMessage(.setFileChecksum, data: newFileChecksum.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - fileTransferCommand

    func setFileTransferCommand(_ fileTransferCommand: BSFileTransferCommand, sendImmediately: Bool = true) {
        logger.debug("setting fileTransferCommand \(fileTransferCommand.name)")
        createAndSendMessage(.setFileTransferCommand, data: fileTransferCommand.data, sendImmediately: sendImmediately)
    }

    // MARK: - fileTransferStatus

    let fileTransferStatusSubject: CurrentValueSubject<BSFileTransferStatus, Never> = .init(.idle)
    var fileTransferStatus: BSFileTransferStatus {
        get { fileTransferStatusSubject.value }
        set {
            fileTransferStatusSubject.value = newValue
            logger.debug("updated fileTransferStatus to \(newValue.name)")
        }
    }

    func getFileTransferStatus(sendImmediately: Bool = true) {
        logger.debug("getting fileTransferStatus")
        createAndSendMessage(.getFileTransferStatus, sendImmediately: sendImmediately)
    }

    func parseFileTransferStatus(_ data: Data) {
        guard let newFileTransferStatus = BSFileTransferStatus.parse(data) else {
            return
        }
        logger.debug("parsed fileTransferStatus \(newFileTransferStatus.name)")
        fileTransferStatus = newFileTransferStatus
    }

    // MARK: - fileTransferBlock

    func parseFileTransferBlock(_ data: Data) {
        guard fileTransferStatus == .receiving else {
            logger.error("cannot parse fileTransferBlock when fileTransferStatus is not .receiving")
            return
        }

        let fileBlockLength = data.count
        logger.debug("received fileBlock of length \(fileBlockLength)")

        var currentFileLength = fileDataToReceive.count
        let newFileLength = currentFileLength + fileBlockLength
        logger.debug("updating fileLength from \(currentFileLength) to \(newFileLength)")

        guard newFileLength <= fileLength else {
            logger.error("newFileLength \(newFileLength) is greater than fileLength \(self.fileLength) - cancelling now")
            cancelFileTransfer()
            return
        }

        fileDataToReceive.append(contentsOf: data)
        currentFileLength = fileDataToReceive.count
        let progress = Float(currentFileLength) / Float(fileLength)
        logger.debug("fileToReceive length \(currentFileLength)/\(self.fileLength) (\(progress)%)")
        fileTransferProgressSubject.send((fileType, .receiving, progress))

        if currentFileLength == fileLength {
            logger.debug("finished receiving file")
            let receivedFileChecksum = fileDataToReceive.crc32()
            guard receivedFileChecksum == fileChecksum else {
                logger.error("file checksums don't match - expected \(self.fileChecksum), got \(receivedFileChecksum)")
                return
            }
            logger.debug("file checksums match \(receivedFileChecksum)")
            fileTransferCompleteSubject.send((fileType, .receiving))
            fileReceivedSubject.send((fileType, fileDataToReceive))
        }
        else {
            createAndSendMessage(.fileBytesTransferred, data: currentFileLength.getData(), sendImmediately: true)
        }
    }

    // MARK: - fileBytesTransferred

    var waitingToSendMoreData: Bool = false
    var bytesTransferred: UInt16 = 0

    func parseFileBytesTransferred(_ data: Data) {
        guard fileTransferStatus == .sending else {
            logger.debug("currently not sending file")
            return
        }
        guard waitingToSendMoreData else {
            logger.debug("not waiting to send more data")
            return
        }

        let currentBytesTransferred: UInt16 = .parse(data)
        logger.debug("currentBytesTransferred: \(currentBytesTransferred)")

        guard currentBytesTransferred == bytesTransferred else {
            logger.error("bytesTransferred not equal - got \(currentBytesTransferred), expected \(self.bytesTransferred)")
            return
        }

        logger.debug("sending next file block")
        sendFileBlock()
    }

    // MARK: - fileTransfer

    let fileTransferProgressSubject: PassthroughSubject<(BSFileType, BSFileTransferDirection, Float), Never> = .init()
    let fileTransferCompleteSubject: PassthroughSubject<(BSFileType, BSFileTransferDirection), Never> = .init()
    let fileReceivedSubject: PassthroughSubject<(BSFileType, Data), Never> = .init()

    var fileDataToReceive: Data = .init()
    var fileDataToSend: Data?

    func sendFile(_ file: inout BSFile, sendImmediately: Bool = true) -> Bool {
        guard fileTransferStatus == .idle else {
            logger.warning("cannot send file - status is \(self.fileTransferStatus.name)")
            return false
        }
        guard let fileData = file.getFileData() else {
            logger.error("unable to get file data")
            return false
        }

        let newFileType = file.fileType
        logger.debug("sending \(newFileType.name) file of length \(fileData.count)")

        let fileChecksum = fileData.crc32()

        if file.fileType == fileType {
            // different file types - sending
        }
        else if fileData.count == fileLength {
            // different file lengths - sending
        }
        else if fileChecksum != self.fileChecksum {
            // different file checksums - sending
        }
        else {
            logger.debug("already sent message")
            return false
        }

        fileDataToSend = fileData

        setFileTransferType(file.fileType, sendImmediately: false)
        setFileLength(UInt16(fileData.count), sendImmediately: false)
        setChecksum(fileChecksum, sendImmediately: false)
        setFileTransferCommand(.send, sendImmediately: sendImmediately)

        return true
    }

    var mtu: UInt16 = 0
    var maxMessageLength: UInt16 { .init(mtu - 3 - 3) }

    func sendFileBlock(sendImmediately: Bool = true) {
        guard fileTransferStatus == .sending else {
            logger.error("cannot send block when fileTransferStatus is \(self.fileTransferStatus.name)")
            return
        }
        guard let fileDataToSend, !fileDataToSend.isEmpty else {
            logger.error("no fileDataToSend")
            return
        }

        let remainingBytes = UInt16(fileDataToSend.count) - UInt16(bytesTransferred)
        logger.debug("remainingBytes: \(remainingBytes)")

        let progress = Float(bytesTransferred) / Float(fileDataToSend.count)
        logger.debug("progress: \(progress)%")
        fileTransferProgressSubject.send((fileType, .sending, progress))

        guard remainingBytes > 0 else {
            logger.debug("finished sending file")
            fileTransferCompleteSubject.send((fileType, .sending))
            waitingToSendMoreData = false
            return
        }
        waitingToSendMoreData = true

        let fileBlockLength = min(remainingBytes, maxMessageLength)
        logger.debug("maxMessageLength: \(self.maxMessageLength), fileBlockLength: \(fileBlockLength)")

        let fileBlockToSend = fileDataToSend.subdata(in: Data.Index(bytesTransferred) ..< Data.Index(bytesTransferred + fileBlockLength))
        bytesTransferred += fileBlockLength
        logger.debug("bytesTransferred: \(self.bytesTransferred)")
        createAndSendMessage(.setFileTransferBlock, data: fileBlockToSend, sendImmediately: sendImmediately)
    }

    func receiveFile(fileType: BSFileType, sendImmediately: Bool = true) {
        guard fileTransferStatus == .idle else {
            logger.debug("cannot receive file - status \(self.fileTransferStatus.name) isn't idle")
            return
        }
        setFileTransferType(fileType, sendImmediately: false)
        setFileTransferCommand(.receive, sendImmediately: sendImmediately)
    }

    func cancelFileTransfer(sendImmediately: Bool = true) {
        guard fileTransferStatus != .idle else {
            logger.warning("fileTransferStatus already idle - no need to cancel")
            return
        }
        logger.debug("cancelling file transfer")
        setFileTransferCommand(.cancel, sendImmediately: sendImmediately)
    }
}
